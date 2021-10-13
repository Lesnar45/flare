#!/bin/sh
nohup sh -c npm start &
exec /app/Jackett/jackett --NoUpdates -p $PORT
