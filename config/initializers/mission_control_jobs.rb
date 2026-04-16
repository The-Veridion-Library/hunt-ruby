# Reuse app admin authentication/authorization for Mission Control Jobs.
MissionControl::Jobs.base_controller_class = "MissionControlController"
MissionControl::Jobs.http_basic_auth_enabled = false
