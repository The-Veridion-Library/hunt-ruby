wt -d "D:\tvbh" --title "Rails Server" pwsh -NoExit -Command "bundle exec rails server" `
	; new-tab -d "D:\tvbh" --title "Vite Server" pwsh -NoExit -Command "bundle exec vite dev" `
	; new-tab -d "D:\tvbh" --title "Jobs Worker" pwsh -NoExit -Command "bundle exec bin/jobs"