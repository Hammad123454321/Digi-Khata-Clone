# Architecture Notes

## Decisions
- Hosting: Hostinger VPS with Nginx reverse proxy and TLS termination.
- OTP/SMS: SendPK (sendpk.com) transactional/OTP route; branded bulk packages are not used for OTP.
- Device cap: default 3 active devices per business (configurable); revocation is immediate.
- WhatsApp sharing: invoices only via share intent; no WhatsApp Business API integration.
