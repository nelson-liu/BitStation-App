BitStation-App
==============

The Kerberos-integrated social wallet

### Bitstation TODO

#### Sending Money
- [ ] Allow coinbase email (non bitstation) recipients
- [x] If recipient kerberos is not on bitstation, send invitation email
- [ ] Recipient kerberos autocomplete from MIT LDAP directory
- [ ] Token
- [ ] Option to save token in the cookie

#### Social
- [x] Public transactions
- [x] Social feeds from public transactions
- [ ] Facebook like

#### Buy/Sell Bitcoin
- [x] Implement buy/sell bitcoin back-end

#### Contacts
- [x] Create contacts db table
- [x] Initialize new user with past coinbase contacts
- [ ] Record new contacts from transactions
- [x] implement add new contact form
- [x] implement contact entry popup with past transactions and receiving addresses
- [ ] Multiple contact addresses
- [ ] More consistent contact address type differentiation.

#### Detailed transaction history view
- [x] Display detailed table
- [x] Transaction filtering in detailed view
- [x] Add messages and annotation to transaction db entries
- [ ] Add messages and annotation in transaction popup

#### Requests
- [x] Save requests in db and display them as pending or satisfied.
- [ ] Use AJAX to respond to money requests.

#### Miscellaneous
- [x] Fix login filter redirect.
- [x] Redirect back to last GET request after login.
- [ ] Test cross-browser support
- [ ] Caching

#### Mobile
- [ ] Shows only transfer module.
- [ ] Homepage tweaks.
