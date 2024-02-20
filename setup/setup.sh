#!/bin/bash

find /opt/setup/setup_steps/ -name "*.sh" | sort -k1 | xargs -I {} bash -c "echo Starting {}; source {}" 2>&1 | tee -a /tmp/hey_alter_setup.log