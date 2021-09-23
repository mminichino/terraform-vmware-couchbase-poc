#!/bin/sh

export LAB_ID=$(terraform output -json | jq -r '."lab-id".value')
