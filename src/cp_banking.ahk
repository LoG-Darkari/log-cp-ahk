cpu(recipient, amount, additional:="")
{ 
RequestType 	:= "POST"
URL 			:= "https://samp.cp.life-of-german.org/home/transfermoney"
Payload 		:= "payer=0&payee=0&payeeUser=" recipient "&money=" amount "&additionalText=" additional "&submit=%C3%9Cberweisen" 

If (recipient = "")
{
    AddChatMessage("{B22222} FEHLER: {FFFFFF} Empfänger darf nicht leer sein!")
    Return false
}
If recipient is digit 
{

   if (IsNPCById(recipient))
   {
       AddChatMessage("{B22222} FEHLER: {FFFFFF} Bots brauchen kein Geld!")
       Return false
   }
   recipient := GetPlayerNameById(recipient)
   if (recipient = GetPlayerName())
   {
     AddChatMessage("{B22222} FEHLER: {FFFFFF} Du kannst dir selbst nichts überweisen.")
  
   }

}
if (Amount < 1 OR Amount  > 20000000)
{
    AddChatMessage("{B22222} FEHLER: {FFFFFF} Betrag muss min. $1 sein und max. $20.000.000")
    Return false
}
if Amount is not digit
{
    AddChatMessage("{B22222} FEHLER: {FFFFFF} Betrag ungültig")
    Return false
}
if (!CP.LoggedIn)
{
    cp_Login()
}

 response := http_Request(RequestType, URL, Payload)
 if (instr(response, "Die Transaktion konnte nicht verarbeitet werden,"))
 {
     AddChatMessage("{B22222} FEHLER: {FFFFFF} Transaktion konnte vom CP nicht verarbeitet werden.")
 }
cp_logout()
 Return true
}
Return
