#!/opt/homebrew/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

echo "[$(date)] Cron fired run-backup-cron.sh" >> /Users/sdubyoo/cron-test.log

"$HOME/Documents/bash-practice/automate-backup.sh" "$HOME/Documents/test" 