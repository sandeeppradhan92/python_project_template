import logging
import time
from datetime import datetime

from flask import Flask, g, redirect, render_template, request, url_for
from flask_wtf.csrf import CSRFError, CSRFProtect

from .config import Config
from .log import create_log_dir, formatter, get_file_handler, get_stream_handler


def create_app(config_class=Config):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_object(config_class)
    csrf = CSRFProtect(app)

    #########################################
    ########  LOGGING CONFIGURATION  ########
    #########################################
    if not app.testing:
        # load the instance config, if it exists, when not testing
        if app.config["LOG_TO_STDOUT"]:
            stream_handler = get_stream_handler()
            app.logger.addHandler(stream_handler)

        create_log_dir(app.config["LOG_DIR"])
        file_handler = get_file_handler(app.config["LOG_DIR"])
        app.logger.addHandler(file_handler)
        app.logger.setLevel(logging.INFO)
        app.logger.info("Application startup")
    else:
        # load the test config if passed in
        pass

    @app.before_request
    def start_timer():
        g.start = time.time()

    @app.after_request
    def after_request(response):
        ## X-Content-Type-Options
        response.headers["X-Content-Type-Options"] = "nosniff"
        ## X-Frame-Options
        response.headers["X-Frame-Options"] = "SAMEORIGIN"
        ## X-XSS-Protection
        response.headers["X-XSS-Protection"] = "1; mode=block"

        ## Logging each request ##
        now = time.time()
        duration = round(now - g.start, 2)
        args = dict(request.args)

        log_params = [
            ("method", request.method),
            ("path", request.path),
            ("status", response.status_code),
            ("duration", duration),
            ("params", args),
        ]

        parts = []
        for name, value in log_params:
            parts.append("{}={}".format(name, value))
        line = " ".join(parts)

        app.logger.info(line)

        return response

    # Import blueprint
    # from app_deployment_manager.api import app as api_bp
    # from app_deployment_manager.blueprint1 import app as bp1

    # app.register_blueprint(bp1)
    # app.register_blueprint(api_bp)

    # Exempt / exclude api service from csrf authentication
    # csrf.exempt(api_bp)

    # a simple echo url for testing
    @app.route("/echo/<string:value>")
    def value(value):
        return value

    @app.route('/ready', methods=["GET"])
    def raedy():
    	return "ok"

    @app.route('/version', methods=["GET"])
    def version():
    	return "0.1"

    @app.errorhandler(CSRFError)
    def handle_csrf_error(e):
        return render_template("csrf_error.html", reason=e.description), 400

    return app


if __name__ == "__main__":
    app = create_app()
