@RestResource(urlMapping='/ResetPassword/*')
global with sharing class ws_ResetPassword
{
    @HttpPost
    global static void handlePost(String portalAuthenticationId, String contactId)
    {
        ResetPasswordHandler.sendResetPasswordEmail(portalAuthenticationId, contactId);
    }
}