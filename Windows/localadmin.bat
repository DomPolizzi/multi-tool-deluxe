echo Adding domain user to local admin group

if /i %userdomain%==domain goto :run
echo no domain
goto :end

:run
net localgroup administrators domain\%computername% /add

:end