# flask_project_template
Folder structure template to structure a flask project

### Building the app from scratch
```python3 setup.py bdist_wheel --python-tag py36 extra_clean```

### For running the app in virtual environment use :
```adm```

---

### Service Installation
- Copy the deployment service file ***deployment_services/adm.service***  to ***/etc/systemd/system/*** in the deployment server
- We must now reload the list of services:

    ```sudo systemctl daemon-reload```

- Then activate the launch of the service at boot:

    ```sudo systemctl enable adm```

- start the service
    
    ```sudo systemctl start adm```

- stop the service

    ```sudo systemctl stop adm```

- check status of the service
    
    ```sudo systemctl status adm```

- For check the logs of the service

    ```journalctl -u service-name.service -b -n 20```

---
