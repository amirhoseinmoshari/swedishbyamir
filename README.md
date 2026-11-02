# Swedish Verb Trainer

A web app for learning 499 Swedish verbs, with English and Persian meanings, examples and audio.
Anyone can sign up with their **email + a one-time code**, and **each account has its own private progress**,
saved online so it follows them between phone and computer. Everyone sees a notice when a **new version** is published.

**Live app:** https://amirhoseinmoshari.github.io/swedish-verb-trainer/

- **Website hosting:** GitHub Pages (free)
- **Sign-in codes + saved progress:** Supabase (free plan)

## Setting up Supabase (once)

1. Go to **supabase.com** → **New project** (pick a region near you, e.g. Stockholm). Wait until it's ready.
2. **Create the database:** **SQL Editor** → **New query** → paste everything from `supabase-schema.sql` → **Run**.
3. **Make the emails contain a code** (not a link): **Authentication → Emails → Templates**. Edit both **Magic link** and **Confirm sign up**, and use this body:
   ```html
   <h2>Your sign-in code</h2>
   <p>Enter this code in Swedish Verb Trainer:</p>
   <h1>{{ .Token }}</h1>
   <p>The code expires in 1 hour. If you didn't ask for it, ignore this email.</p>
   ```
4. **Authentication → URL Configuration** → set **Site URL** to the live app address above.
5. **Project Settings → API Keys**: copy the **Project URL** and the **publishable key** (`sb_publishable_…`, or the older **anon public** key) into `config.js`:
   ```js
   window.APP_CONFIG = {
     SUPABASE_URL: "https://xxxxxxxx.supabase.co",
     SUPABASE_KEY: "sb_publishable_xxxxxxxx"
   };
   ```
   ⚠️ Never put the **secret** / **service_role** key anywhere in this project.
6. **Recommended — a real email sender.** Supabase's built-in email is for testing and only sends a few emails per hour. Connect a free sender such as **Resend** or **Brevo** in **Authentication → Emails → SMTP Settings**.

## Using it

Share the link. People enter their email, type the code they receive, and start learning. Their progress is saved to their own account.

**On phones:** open the website, then *Share → Add to Home Screen* (iPhone, Safari) or *⋮ → Add to Home screen* (Android, Chrome).

## Publishing a new version

1. In `index.html`, raise `APP_VERSION` by 1, update `APP_LABEL`, and add a line to `CHANGELOG`.
2. In `version.json`, set the **same** `version` and `label`, and a short note.
3. Commit both. Users see **"New version is ready — Update now"** within a few minutes, and a **What's new** note after updating.

## Files

| File | What it is |
|---|---|
| `index.html` | The whole app (all 499 verbs are inside) |
| `config.js` | Your Supabase address and public key |
| `version.json` | The newest version number (drives the update notice) |
| `supabase-schema.sql` | Database table and privacy rules — run once in Supabase |
| `manifest.json`, `icon-*.png` | Lets phones add the app to the home screen |

## Privacy

Each account can only read and write **its own** progress. This is enforced by the database itself, not just the app.
