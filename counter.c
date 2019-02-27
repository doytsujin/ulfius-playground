#include <ulfius.h>
#include <hiredis/hiredis.h>

long int local_hw = 0;
long int local_count = 0;
long int local_ping = 0;

// create redis context and test it works!
redisContext *redisConn(){

    // check variables or set defaults
    const char *redis_ip = getenv("REDIS_IP") ? getenv("REDIS_IP") : "127.0.0.1";
    const int redis_port = 
        ( getenv("REDIS_PORT") == NULL || atoi(getenv("REDIS_PORT")) == 0) ? 6379 : atoi(getenv("REDIS_PORT")) ;

    redisContext *c = redisConnect(redis_ip, redis_port);
    redisReply *reply;

   // create connection
    if (c == NULL || c->err) {
        if (c) {
            y_log_message(Y_LOG_LEVEL_ERROR, "Error: %s", c->errstr);
        } else {
            y_log_message(Y_LOG_LEVEL_ERROR, "Connection error: can't allocate redis context" );
        }
	redisFree(c);
    	return (redisContext *)NULL;
    }


   // check connection works
    reply = redisCommand(c,"PING");
    if ( c->err ) {
        y_log_message(Y_LOG_LEVEL_ERROR, "Error: %s", c->errstr);
        redisFree(c);
        return (redisContext *)NULL;
    }

    freeReplyObject(reply);
    return c;

}

// Callback functions

// our default - better than a blank page
int callback_hello_world (const struct _u_request * request, struct _u_response * response, void * user_data) {
  local_hw++;
  ulfius_set_string_body_response(response, 200, "Hello World!");
  return U_CALLBACK_CONTINUE;
}


// to test redis connection
int callback_health (const struct _u_request * request, struct _u_response * response, void * user_data) {

    redisContext *c = redisConn();

    if (c == NULL){
        redisFree(c);
        return U_CALLBACK_ERROR;
    }

    local_ping++;
    ulfius_set_string_body_response(response, 200, "OK");

    redisFree(c);

    return U_CALLBACK_CONTINUE;
}


// to increment by one
int callback_count (const struct _u_request * request, struct _u_response * response, void * user_data) {

    char * response_message;

    redisContext *c = redisConn();
    redisReply *reply;

    if (c == NULL){
        redisFree(c);
        return U_CALLBACK_ERROR;
    }

    redisAppendCommand(c,"INCR counter");
    redisGetReply(c, (void **)&reply);

    if ( reply->type == REDIS_REPLY_ERROR) {
        y_log_message(Y_LOG_LEVEL_ERROR, "Error incremeting: %s", reply->str);
        ulfius_set_string_body_response(response, 429, "BAD");
    } else {
        local_count++;
        if ( getenv("DEBUG") )
		y_log_message(Y_LOG_LEVEL_DEBUG, "INCR: %lld", reply->integer);

        response_message = msprintf("%lld", reply->integer);
        ulfius_set_string_body_response(response, 200, response_message);
        o_free(response_message);

    }

    freeReplyObject(reply);
    redisFree(c);

    return U_CALLBACK_CONTINUE;
}


// to get metrics of our endpoints
int callback_metrics (const struct _u_request * request, struct _u_response * response, void * user_data) {

    char * response_message;

    redisContext *c = redisConn();
    redisReply *reply;

    if (c == NULL){
        redisFree(c);
        return U_CALLBACK_ERROR;
    }

    redisAppendCommand(c,"GET counter");

    redisGetReply(c, (void **)&reply);

    if ( reply->type == REDIS_REPLY_ERROR ) {
        y_log_message(Y_LOG_LEVEL_ERROR, "Error collecting metrics : %s", reply->str);
        ulfius_set_string_body_response(response, 429, "BAD");
    } else {
        if ( getenv("DEBUG") )
            y_log_message(Y_LOG_LEVEL_DEBUG, "serving metrics");

        response_message = msprintf("global_count %s\nlocal_hw %lld\nlocal_count %lld\nlocal_ping %lld",
                reply->str, local_hw, local_count, local_ping);
        ulfius_set_string_body_response(response, 200, response_message);
        o_free(response_message);
    }

    freeReplyObject(reply);
    redisFree(c);

    return U_CALLBACK_CONTINUE;
}



// main function
int main(void) {

    // check variables or set defaults
    const int port = ( getenv("PORT") == NULL || atoi(getenv("PORT")) == 0) ? 8080 : atoi(getenv("PORT")) ;

    struct _u_instance instance;

    // initialize logs
    y_init_logs("test", Y_LOG_MODE_CONSOLE, Y_LOG_LEVEL_DEBUG, NULL, "Starting test");

    // initialize instance with the port number
    if (ulfius_init_instance(&instance, port, NULL, NULL) != U_OK) {
        y_log_message(Y_LOG_LEVEL_ERROR, "Error ulfius_init_instance, abort");
        return(1);
    }

    u_map_put(instance.default_headers, "Access-Control-Allow-Origin", "*");

    // Endpoint list declaration
    ulfius_add_endpoint_by_val(&instance, "GET", "/hw", NULL, 0, &callback_hello_world, NULL);
    ulfius_add_endpoint_by_val(&instance, "GET", "/count", NULL, 0, &callback_count, NULL);
    ulfius_add_endpoint_by_val(&instance, "GET", "/health", NULL, 0, &callback_health, NULL);
    ulfius_add_endpoint_by_val(&instance, "GET", "/metrics", NULL, 0, &callback_metrics, NULL);

    // default_endpoint declaration
    ulfius_set_default_endpoint(&instance, &callback_hello_world, NULL);

    // Start the framework
    if (ulfius_start_framework(&instance) == U_OK) {
        y_log_message(Y_LOG_LEVEL_INFO, "Start framework on port %d", instance.port);

        // run forever
        for (;;){};

    } else {
            y_log_message(Y_LOG_LEVEL_ERROR, "Error starting framework");
    }

    // end logs
    y_log_message(Y_LOG_LEVEL_DEBUG, "End framework");
    y_close_logs();

    // end framework
    ulfius_stop_framework(&instance);

    // end instance
    ulfius_clean_instance(&instance);

    return 0;
}
