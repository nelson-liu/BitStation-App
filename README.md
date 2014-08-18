BitStation-App
==============

The Kerberos-integrated social wallet

### Bitstation TODO

#### Sending Money
- [ ] Allow coinbase email (non bitstation) recipients
- [ ] If recipient kerberos is not on bitstation, send invitation email
- [ ] Recipient kerberos autocomplete from MIT LDAP directory

#### Social
- [ ] Public transactions
- [ ] Social feeds from public transactions

#### Buy/Sell Bitcoin
- [ ] Implement buy/sell bitcoin back-end

#### Contacts
- [x] Create contacts db table
- [x] Initialize new user with past coinbase contacts
- [ ] Record new contacts from transactions
- [ ] implement add new contact form
- [ ] implement contact entry popup with past transactions and receiving addresses

#### Detailed transaction history view
- [x] Display detailed table
- [x] Transaction filtering in detailed view
- [ ] Add messages and annotation to transaction db entries
- [ ] Add messages and annotation in transaction popup
- [ ] Add transaction labels for user organization

#### Requests
- [x] Save requests in db and display them as pending or satisfied.
- [ ] Use AJAX to respond to money requests.

#### Miscellaneous
- [x] Fix login filter redirect.
- [x] Redirect back to last GET request after login.
