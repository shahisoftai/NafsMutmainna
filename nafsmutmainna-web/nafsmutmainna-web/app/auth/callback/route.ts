import { NextResponse, type NextRequest } from "next/server";
import { createServerClient } from "@supabase/ssr";

export async function GET(request: NextRequest) {
    const { searchParams, origin } = new URL(request.url);
    const code = searchParams.get("code");
    const next = searchParams.get("next") ?? "/dashboard";
    const errorParam = searchParams.get("error");
    const errorDescription = searchParams.get("error_description");

    const redirectToLogin = (message: string) => {
        const loginUrl = new URL("/auth/login", origin);
        loginUrl.searchParams.set("error", message);
        return NextResponse.redirect(loginUrl);
    };

    if (errorParam) {
        return redirectToLogin(errorDescription || errorParam);
    }

    if (!code) {
        return redirectToLogin("Missing authorization code");
    }

    // Route handlers must use request/response cookies, not next/headers.
    // CRITICAL: do NOT force httpOnly:true — the browser client reads
    // session cookies via document.cookie and cannot read httpOnly cookies.
    // Supabase's DEFAULT_COOKIE_OPTIONS already sets httpOnly:false.
    const response = NextResponse.redirect(new URL(next, origin));

    const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
            cookies: {
                getAll() {
                    return request.cookies.getAll();
                },
                setAll(cookiesToSet) {
                    cookiesToSet.forEach(({ name, value, options }) => {
                        response.cookies.set(name, value, options);
                    });
                },
            },
        }
    );

    const { error } = await supabase.auth.exchangeCodeForSession(code);

    if (error) {
        return redirectToLogin(error.message);
    }

    return response;
}
