using Microsoft.Owin;
using Owin;
using Microsoft.Owin.Security.Cookies;
using Microsoft.AspNet.Identity;

[assembly: OwinStartup(typeof(ONLINE_RESTURANT_1.Startup))]

namespace ONLINE_RESTURANT_1
{
    public class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            // Configure authentication
            app.UseCookieAuthentication(new CookieAuthenticationOptions
            {
                AuthenticationType = DefaultAuthenticationTypes.ApplicationCookie,
                LoginPath = new PathString("/User/Login")
            });
        }
    }
}
