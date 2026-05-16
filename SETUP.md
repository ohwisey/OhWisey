# Oh Wisey — Setup Guide

Get your dashboard live on the web and syncing your standalones across devices. **~10 minutes**, zero terminal commands required.

You'll do three things:
1. **Deploy** the folder to Vercel so you can open it on your phone, laptop, anywhere
2. **Create a Supabase project** so your standalones (workout logger, sleep log, etc.) sync across those devices
3. **Connect them** in the dashboard's settings panel

> **Important:** The dashboard's tile list lives in code — in the `TILES` array at the top of `index.html`. Supabase is **only** for syncing the data your standalones produce (workouts, weights, etc.), not the tile list itself. Adding a tile = editing the file + pushing to git. That's by design.

---

## Before you start

Make sure you have free accounts at:
- **GitHub** — https://github.com
- **Vercel** — https://vercel.com (sign up with your GitHub account)
- **Supabase** — https://supabase.com (sign up with your GitHub account)

No credit card, no installs.

---

## 1 · Put the folder on GitHub

The easiest path: drag-and-drop on github.com.

1. Go to https://github.com/new
2. Repo name: `OhWisey` (or your own)
3. Public or Private — public lets viewers fork it (recommended)
4. Click **Create repository**
5. On the empty repo page, click **uploading an existing file**
6. Drag your `OhWisey` folder contents into the page (the `index.html`, `supabase/`, this `SETUP.md`, everything)
7. Scroll down → **Commit changes**

---

## 2 · Deploy to Vercel

1. Go to https://vercel.com/new
2. Click **Import** next to your repo
3. Leave every setting at default — it's static HTML
4. Click **Deploy**

After ~20 seconds you'll get a live URL like `oh-wisey.vercel.app`. Open it on your phone — that's your dashboard, anywhere.

> Every git push redeploys automatically. Adding a tile = editing the `TILES` array + `git push`.

---

## 3 · Create a Supabase project

1. Go to https://supabase.com/dashboard
2. **New project**
3. Pick a name, a strong database password (save it), and a region near you
4. **Create new project** — wait ~1 minute

---

## 4 · Run the schema

This creates the `app_data` table your standalones will use, plus row-level-security rules that keep your data private.

1. Supabase → **SQL Editor** → **New query**
2. Open `supabase/schema.sql` from this folder, copy everything, paste it in
3. **Run** (Cmd/Ctrl+Enter)

You should see **Success. No rows returned.**

---

## 5 · Configure auth redirects

So magic-link sign-in works when you click the email link.

1. Supabase → **Authentication → URL Configuration**
2. **Site URL** → your Vercel URL (e.g. `https://oh-wisey.vercel.app`)
3. **Redirect URLs** → add:
   - `https://oh-wisey.vercel.app/**`
   - `http://localhost:*/**`
4. **Save**

---

## 6 · Grab your URL + key

1. Supabase → **Project Settings → API**
2. Copy **Project URL** (`https://xxxxxxxx.supabase.co`)
3. Copy the **Publishable key** (starts with `sb_publishable_…`) OR the legacy **anon / public** key (the long `eyJ…` JWT). Either works — never the **secret** / **service_role** key.

> **Why it's safe in the browser:** Row-level security (which you turned on in step 4) means a stolen publishable/anon key still can't read or write anyone else's data.

---

## 7 · Connect the dashboard

1. Open your Vercel URL
2. Click the **⚙ gear** (top-right)
3. Paste the Supabase URL and key → **Save credentials**
4. Type your email → **Send magic link**
5. Check your email, click the link
6. You'll bounce back. The dot next to OH·WISEY turns solid mint = signed in.

---

## Adding a standalone (the everyday flow)

This is the workflow you're teaching your audience. There's no UI for it — that's the point.

1. **Build the standalone.** A single HTML file in its own folder (e.g. `workout-logger/index.html`) or a separate repo deployed to GitHub Pages.
2. **Open `index.html`** in your editor.
3. **Find the `TILES` array** at the top of the `<script>` block (clearly marked with `EDIT HERE TO ADD A TILE`).
4. **Add an entry:**
   ```js
   {
     name: 'Workout Logger',
     icon: '🏋️',
     url:  './workout-logger/',
     desc: 'Log sets, reps, and PRs',
   }
   ```
5. **Push:** `git add . && git commit -m "feat: add workout logger" && git push`
6. Vercel redeploys in ~20s. Tile appears.

---

## How standalones sync their own data

Each standalone reads the dashboard's Supabase session and writes its data to the `app_data` table under its own `app_slug`. Skeleton:

```js
// In your standalone (running inside the dashboard or opened as a new tab)
const session = window.opener?.ohwisey?.session;   // inherited from dashboard
const supabase = window.opener?.ohwisey?.supabase;

if (session && supabase) {
  await supabase.from('app_data').upsert({
    user_id:  session.user.id,
    app_slug: 'workout-logger',
    key:      '2026-05-15',
    value:    { sets: [...], notes: '...' },
  });
}
```

RLS makes sure each user only sees their own rows. Two users using the same standalone in the same browser would never see each other's data.

---

## Troubleshooting

**Magic link goes to an error page**
→ Redirect URL in Supabase doesn't match. Step 5 — make sure your Vercel URL is in there with `/**` on the end.

**"Could not connect to Supabase"**
→ Check URL has `https://` and ends in `.supabase.co`. Make sure the key is publishable or anon — never service_role.

**403 errors in DevTools console after signing in**
→ Schema didn't grant the `authenticated` role table access. Re-run `supabase/schema.sql` — the `grant` statements at the bottom fix this.

**Sync dot stays gray/red**
→ Open DevTools → Console. The error tells you exactly what's wrong.

**Can my viewers use this?**
→ Yes. Forking the GitHub repo gets them a clean copy. They edit their own `TILES` array, deploy to their own Vercel, optionally connect their own Supabase project. Their data never touches yours.

---

## What's where

```
OhWisey/
├── index.html              ← dashboard + TILES array
├── SETUP.md                ← this file
├── supabase/
│   └── schema.sql          ← run in Supabase SQL editor (step 4)
└── workout-logger/         ← your standalones live in folders next to the dashboard
    └── index.html
```

That's the whole system.
