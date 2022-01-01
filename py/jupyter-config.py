import os
from IPython.lib import passwd

if os.getenv("JUPYTER_PASSWORD"):
    c.ServerApp.password = passwd(os.getenv("JUPYTER_PASSWORD"))

if os.getenv("JUPYTER_ROOT"):
    c.ServerApp.root_dir = os.getenv("JUPYTER_ROOT")

c.ServerApp.allow_password_change = False
c.ServerApp.terminado_settings = { "shell_command": ["/bin/zsh"] }
c.ServerApp.allow_root = True
c.ServerApp.ip = "0.0.0.0"
c.ExtensionApp.open_browser = False
