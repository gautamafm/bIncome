#!/bin/bash
python -m clean.io.psid --rebuild-down
python -m clean.bank_panels
stata do clean/make_panel_with_weights.do
stata do clean/make_ES_data.do
