#include <ulfius.h>

// Callback functions

// our default - better than a blank page
int callback_hello_world (const struct _u_request * request, struct _u_response * response, void * user_data) {
  ulfius_set_string_body_response(response, 200, "Hello World!");
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
    ulfius_add_endpoint_by_val(&instance, "GET", "/hello_world", NULL, 0, &callback_hello_world, NULL);

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
