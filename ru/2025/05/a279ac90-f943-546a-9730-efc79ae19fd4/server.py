# Serving a Static Answer File via Python.
# proxmox-fetch-answer http http://192.168.1.2:8000/answer > /run/automatic-installer-answers && exit

import logging
from aiohttp import web

routes = web.RouteTableDef()


@routes.post("/answer")
async def answer(request: web.Request):
    logging.info(f"Received request from peer '{request.remote}'")
    file_contents = app.get("answer_file", None)
    if file_contents is None:
        return web.Response(status=404, text="not found")
    return web.Response(text=file_contents)


if __name__ == "__main__":
    app = web.Application()
    with open("answer.toml") as answer_file:
        file_contents = answer_file.read()
    app["answer_file"] = file_contents
    logging.basicConfig(level=logging.INFO)
    app.add_routes(routes)
    web.run_app(app, host="0.0.0.0", port=8000)
