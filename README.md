# peeps
A lightweight contact and org/acronym tracker

Do you find yourself working at a job where you're drowning in alphabet soup?  Too much network taxing your limited memory resources?  Do you go to meetings where it's acceptable to have a laptop open, and everyone only half paying attention is the norm?

If you answered yes to all these questions, you're in luck!  peeps is a lightweight set of commands for the terminal that allow you to discretely lookup your past notes on the most recent name-drop, while appearing to just be taking notes or firing off an email.

### Requirements

sqlite3 installed and on your path.  You'll need to run install.sh and follow the instructions there (or use daveycrockett/quickstart if you're into that sort of thing).

### Commands

Run ```peeps help``` or ```orgs help``` for complete list of commands.  A few examples are listed here.

Adding an organization:

    $ orgs add
    name: United Nations Foundation
    acronym: UNF

Appending notes to an organization:

    $ orgs note UNF
    notes: Where I currently work

    $ orgs who UN
    name                       acronym     notes                             
    -------------------------  ----------  ----------------------------------
    united nations foundation  UNF         
    2017-03-30
    Where I currently work

Adding a contact (with partial information):

    $ peeps add
    name: david mccann
    email:        
    org acronym: UNF
    org name: 
    notes: me

Appending notes to a contact: 

    $ peeps note "david mccann"
    notes: likes bash a little too much

Searching contacts:

    $ peeps who dav
    name          email       orgname     acronym     notes                                                  
    ------------  ----------  ----------  ----------  -------------------------------------------------------
    david mccann                          UNF         

    2017-03-30
    me
    2017-03-30
    likes bash a little too much

Searching contacts by org:

    $ peeps whoin UNF
    name          email       orgname     acronym     notes                                                  
    ------------  ----------  ----------  ----------  -------------------------------------------------------
    david mccann                          UNF         
    
    2017-03-30
    me
    2017-03-30
    likes bash a little too much

Adding more information to a contact:

    $ peeps add
    name: david mccann
    email: d@added-an-email.com
    org acronym: 
    org name: 
    notes: 

Adding info doesn't clobber old info:

    $ peeps who dav
    name          email                 orgname     acronym     notes                                                                     
    ------------  --------------------  ----------  ----------  --------------------------------------------------------------------------
    david mccann  d@added-an-email.com              UNF         
    
    2017-03-30
    me
    2017-03-30
    likes bash a little too much

    2017-03-30
