def healthcheck():
    """Healthcheck Endpoint
    ---
    responses:
      200:
        description: Service is healthy
    """
    return {"status": "ok"}, 200
