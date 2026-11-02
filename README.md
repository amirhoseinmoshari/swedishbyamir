# Swedish Verb Trainer

A web app for learning 499 Swedish verbs, with English and Persian meanings, examples and audio.
Learners sign in with their **email + a one-time code**, the **owner approves** them, and each learner's
progress is **saved privately** to their account. Everyone sees a notice when a **new version** is published.

- **Website hosting:** GitHub Pages (free)
- **Sign-in codes + database:** Supabase (free plan)

Setup takes about 20 minutes. Do the steps in order.

---

## Part 1 — Put the app on GitHub

1. Sign in at **github.com** (create a free account if needed).
2. Click **+** (top right) → **New repository**. Name it `swedish-verb-trainer`, choose **Public**, click **Create repository**.
3. On the new page click **uploading an existing file**. Drag in **all files** from this zip. Click **Commit changes**.
4. Go to **Settings → Pages**. Under *Build and deployment* choose **Deploy from a branch**, branch **main**, folder **/(root)**, then **Save**.
5. After 1–2 minutes your app is at:
   `https://YOUR-GITHUB-NAME.github.io/swedish-verb-trainer/`
   It will say **"Setup needed"** until you finish Part 2. That's expected.

## Part 2 — Set up Supabase (sign-in codes and saved progress)

1. Go to **supabase.com** → sign up → **New project**. Pick a name, a database password (save it), and a region near you (e.g. Stockholm). Wait until the project is ready.
2. **Create the database:** open **SQL Editor** → **New query**. Open `supabase-schema.sql` from this zip, copy everything, paste it in.
   **Replace `OWNER_EMAIL@example.com` with your own email** (this makes you the owner who approves people). Click **Run**. It should say *Success*.
3. **Make the emails contain a code** (not a link): go to **Authentication → Emails → Templates**.
   Edit both **Magic link** and **Confirm sign up**. Replace the message body with:
   ```html
   <h2>Your sign-in code</h2>
   <p>Enter this code in Swedish Verb Trainer:</p>
   <h1>{{ .Token }}</h1>
   <p>The code expires in 1 hour. If you didn't ask for it, ignore this email.</p>
   ```
   Click **Save** on each.
4. **Tell Supabase your website address:** **Authentication → URL Configuration** → set **Site URL** to your GitHub Pages address from Part 1.
5. **Connect the app to Supabase:** open **Project Settings → API Keys** (or **API**). Copy the **Project URL** and the **publishable key** (starts with `sb_publishable_`, or the older **anon public** key).
   On GitHub open `config.js` → click the ✏️ pencil → paste them between the quotes → **Commit changes**:
   ```js
   window.APP_CONFIG = {
     SUPABASE_URL: "https://xxxxxxxx.supabase.co",
     SUPABASE_KEY: "sb_publishable_xxxxxxxx"
   };
   ```
   ⚠️ Never paste the **secret** / **service_role** key anywhere in this project.
6. **Strongly recommended — a real email sender.** Supabase's built-in email is only for testing and can send just a few emails per hour, so learners may not get their codes. Create a free account at an email service such as **Resend** or **Brevo**, then enter its SMTP details in **Authentication → Emails → SMTP Settings**.

## Part 3 — Start using it

1. Open your website, enter **your** email, type the code you receive. You're the owner, so you get in straight away and see a **👥 Learners** tab.
2. Send the website link to your students. They sign in with their email and code, then see **"Waiting for approval"**.
3. In **Learners**, tap **Approve**. Their app opens (they can tap **Check now**, or it updates within ~20 seconds).
4. You can **Remove** someone later; their progress is kept in case you approve them again.

**Add another approver:** in Supabase **SQL Editor** run
`insert into public.app_admins (email) values ('their@email.com');`

**On phones:** open the website, then *Share → Add to Home Screen* (iPhone, Safari) or *⋮ → Add to Home screen* (Android, Chrome). It opens like an app.

## Publishing a new version

When you (or Claude) change the app:

1. In `index.html`, raise `APP_VERSION` by 1 (e.g. `6` → `7`), update `APP_LABEL` (e.g. `"2.1"`), and add a line to `CHANGELOG` describing the change.
2. In `version.json`, set the **same** `version` and `label`, and a short note.
3. Commit both files. Anyone using the app sees **"New version is ready — Update now"** within a few minutes, and a **What's new** note after updating.

## Files

| File | What it is |
|---|---|
| `index.html` | The whole app (all 499 verbs are inside) |
| `config.js` | Your Supabase address and public key |
| `version.json` | The newest version number (drives the update notice) |
| `supabase-schema.sql` | Database tables and security rules — run once in Supabase |
| `manifest.json`, `icon-*.png` | Lets phones add the app to the home screen |

## Privacy and security

- Each learner can only read and write **their own** progress — enforced by the database, not just the app.
- Only owners (emails in `app_admins`) can see the learner list and approve or remove people.
- Unapproved accounts cannot save anything.
- The verb list is part of the website itself, so anyone with the link can technically view the page source; approval controls who can **use and save progress** in the app.
