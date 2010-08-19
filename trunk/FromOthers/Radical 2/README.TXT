Radical 2 - Remote Administration Over the TCP Protocol
Author: Andrew Dunn AKA Hallman
=======================================================

Radical 2 is designed to be a simple, yet powerfull administration tool
for a small lab of computers (2 - 25 machines). The server is written in
C# to take advantage of multi threading, while the client is written in 
AutoIt3 for simplicity, and compatibility. Radical 2 is in it's beta
stages so there are probably a lot of kinks to work out. If you encounter
any bugs please let me know so I can fix them!

=======================================================

Requirements:

- The server should run on Windows XP and newer. The client is written 
  in AutoIt3 so it should run on just about anything ;)

- .NET framework 3.5, which can be found here: 
  http://www.microsoft.com/downloads/details.aspx?FamilyID=333325fd-ae52-4e35-b531-508d977d32a6&DisplayLang=en

- LAN with 2 or more computers

- Port 1451 (can be changed in options) open in firewall

=======================================================

To get started:

- Run the server on the machine that you want to be the server.
  Click Yes when it asks if you want to create a new settings file.
  Make sure your fire wall isn't blocking it!
  Don't edit the port number in Server\Settings.xml unless you have too.

- On each client machine, open Client\Settings.ini
    - Edit "IP" to the servers IP address
    - Edit "username" to whatever you want
    - Run "Client.au3"

Note: The client script runs in the background without a GUI so don't expect 
anything to pop up on the screen.

- Now go back to your server. The list on the left should have all all the
  clients listed. If not, go back and make sure you typed in the correct IP.

- Select a client from the list, then using the various tabs play around with
  the controls.