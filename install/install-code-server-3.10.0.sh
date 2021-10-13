#!/bin/bash
set -x
curl -fsSL https://code-server.dev/install.sh -o /tmp/install.sh && chmod +x /tmp/install.sh
mkdir -p /opt/coder/{user-data,extensions}
/bin/bash /tmp/install.sh --prefix=/opt/coder --method standalone
cat > /opt/coder/config.yaml << EOL
bind-addr: 0.0.0.0:8443
auth: password
hashed-password: de01e80cd6e83b8973b2d1363fd08d210223bedb5ce8eeb466ba626bcb867867
user-data-dir: /opt/coder/user-data
extensions-dir: /opt/coder/extensions
cert: false
EOL

[ ! -d /odoo/.vscode ] && mkdir -p /odoo/.vscode

cat > /odoo/.vscode/launch.json <<@EOF
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Odoo 14",
            "type": "python",
            "request": "launch",
            "console": "integratedTerminal",
            "showReturnValue": true,
            "program": "/odoo/src/odoo-bin",
            "args": [
                "--config=/etc/odoo.cfg",
                "--dev=all",
                "--workers=0",
            ]
        }
    ]
}
@EOF

[ ! -d /opt/coder/user-data/User ] && mkdir -p /opt/coder/user-data/User
cat > /opt/coder/user-data/User/settings.json <<@EOF
{
    "python.pythonPath": "/usr/bin/python3",
    "workbench.colorTheme": "Default Dark+",
    "workbench.startupEditor": "newUntitledFile",
    "extensions.autoCheckUpdates": false,
    "extensions.autoUpdate": false,
    "editor.fontLigatures": null,
    "files.watcherExclude": {
        "**/.git/objects/**": true,
        "**/.git/subtree-cache/**": true,
        "**/.gitlab/**": true,
        "**/odoo/data/**": true
    },
    "files.exclude": {
        ".vscode": true,
        "before-migrate-entrypoint.d": true,
        "bin": true,
        "scripts": true,
        "songs": true,
        "start-entrypoint.d": true,
        "templates": true,
        "Dockerfile": true
    }
}
@EOF

# require installation of ms-python from open-vsx https://open-vsx.org/extension/ms-python/python
curl -fsSL https://github.com/microsoft/vscode-python/releases/download/2020.10.332292344/ms-python-release.vsix -o /tmp/ms-python-release.vsix
/opt/coder/bin/code-server --config /opt/coder/config.yaml /odoo \
--install-extension /tmp/ms-python-release.vsix \
--install-extension redhat.vscode-xml \
--install-extension redhat.vscode-yaml \
--install-extension dbaeumer.vscode-eslint