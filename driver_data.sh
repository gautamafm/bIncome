#!/bin/bash
python -m clean.psid.io --rebuild-all
python -m clean.bank_panels
stata do clean/make_panel_with_weights.do
stata do clean/make_ES_data.do
