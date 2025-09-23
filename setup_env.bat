@echo off
echo Setting up secure environment configuration...

echo Creating .env file for development...
echo SUPABASE_URL=https://jalkqdrzbfnklpoerwui.supabase.co > .env
echo SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImphbGtxZHJ6YmZua2xwb2Vyd3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODA0NjMsImV4cCI6MjA3MzE1NjQ2M30.JNjLRdtDJTFKhhQEtpAtlXOpRR1Tu051tClaE3PTino >> .env

echo Adding .env to .gitignore...
echo .env >> .gitignore
echo env.json >> .gitignore

echo Environment setup complete!
echo Remember to use: flutter run --dart-define-from-file=.env