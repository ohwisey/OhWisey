# Oh Wisey — Setup Guide

Get your dashboard live on the web and syncing across devices. **~10 minutes**, zero terminal commands required (CLI shortcuts noted where they help).

You'll do three things:
1. **Deploy** the folder to Vercel so you can open it on your phone, laptop, anywhere
2. **Create a Supabase project** so your tiles sync across those devices
3. **Connect them** in the dashboard's settings panel

---

## Before you start

Make sure you have free accounts at:
- **GitHub** — https://github.com
- **Vercel** — https://vercel.com (sign up with your GitHub account)
- **Supabase** — https://supabase.com (sign up with your GitHub account)

That's it. No credit card, no installs.

---

## 1 · Put the folder on GitHub

The easiest path: drag-and-drop on github.com.

1. Go to https://github.com/new
2. Repo name: `OhWisey` (or whatever you want)
3. Public or Private — your call. Public lets viewers fork it.
4. Click **Create repository**
5. On the empty repo page, click **uploading an existing file**
6. Drag your entire `OhWisey` folder contents into the page (the `index.html`, the `supabase/` folder, this `SETUP.md`, everything)
7. Scroll down → **Commit changes**

Done. Your code is on GitHub.

---

## 2 · Deploy to Vercel

1. Go to https://vercel.com/new
2. Click **Import** next to your `OhWisey` repo
3. Leave every setting at default — there's nothing to build, it's just static HTML
4. Click **Deploy**

After ~20 seconds you'll get a live URL like `oh-wisey.vercel.app`. Open it on your phone. That's your dashboard, anywhere.

> **Every git push redeploys automatically.** Edit a file on GitHub.com or push from your computer — Vercel rebuilds in seconds.

---

## 3 · Create a Supabase project

1. Go to https://supabase.com/dashboard
2. **New project**
3. Pick a name (e.g. `oh-wisey`), a strong database password (save it — you won't need it often), and a region near you
4. Click **Create new project** and wait ~1 minute for it to spin up

---

## 4 · Run the schema

This creates the tables and the row-level-security rules that keep your data private.

1. In your Supabase project, click **SQL Editor** in the left sidebar
2. Click **New query**
3. Open `supabase/schema.sql` from this folder, copy everything, paste it into the SQL editor
4. Click **Run** (or Cmd/Ctrl+Enter)

You should see "Success. No rows returned." Done.

---

## 5 · Configure auth redirects

So magic-link sign-in actually works when you click the email link.

1. In Supabase, go to **Authentication → URL Configuration** (left sidebar)
2. **Site URL** → paste your Vercel URL (e.g. `https://oh-wisey.vercel.app`)
3. **Redirect URLs** → add both of these:
   - `https://oh-wisey.vercel.app/**`
   - `http://localhost:*/**` *(so you can also test by opening the file locally)*
4. **Save**

---

## 6 · Grab your URL + anon key

1. In Supabase, go to **Project Settings → API** (gear icon at bottom-left)
2. Copy the **Project URL** (looks like `https://xxxxxxxx.supabase.co`)
3. Copy the **anon / public** key (the long `eyJ…` one — **NOT** the service_role key)

> **Why it's safe to put the anon key in the browser:** Supabase is designed for this. Row-level security (which you just turned on in step 4) means a stolen anon key still can't read or write anyone else's data. Never paste the **service_role** key into the browser — that one bypasses RLS.

---

## 7 · Connect the dashboard

1. Open your Vercel URL
2. Click the **⚙ gear** in the top-right
3. Paste the Supabase URL and anon key → **Save credentials**
4. Type your email → **Send magic link**
5. Check your email, click the link
6. You'll bounce back to the dashboard. The dot next to the OH·WISEY logo turns solid mint = synced.

Now open the same URL on your phone, sign in with the same email, and you'll see the same tiles. That's the sync.

---

## Adding a standalone (the everyday flow)

Every time you build a new standalone for a video:

1. Make a folder next to `index.html`, e.g. `workout-logger-standalone/`
2. Put your single-file app in there as `index.html`
3. Push to GitHub (drag-and-drop on github.com is fine)
4. Vercel redeploys in ~20 seconds
5. Open your dashboard, hit **+ Add standalone**, paste the path (`./workout-logger-standalone/index.html`), name it, give it an emoji
6. Tile syncs to your phone instantly

---

## Troubleshooting

**Magic link goes to an error page**
→ The redirect URL in Supabase doesn't match. Go back to step 5 and make sure your Vercel URL is in there with `/**` on the end.

**"Could not connect to Supabase"**
→ Double-check the URL has `https://` and ends in `.supabase.co`. Double-check the anon key is the **anon** one, not service_role.

**Sync dot stays amber/red**
→ Open browser DevTools console (right-click → Inspect → Console). The error message will tell you what's wrong — usually a typo'd key or a missed SQL step.

**I want to wipe everything and start fresh**
→ Settings → **Disconnect Supabase**. That clears the credentials. Then in Supabase, **Table Editor → dashboard_config → delete your row**. You're clean.

**Can my viewers use this?**
→ Yes. The dashboard works fully offline by default — they just open the page and add tiles. Cloud sync is opt-in. If they want sync, they create their own Supabase project and paste their own keys. Their data never touches yours.

---

## What's where

```
OhWisey/
├── index.html              ← the dashboard itself
├── SETUP.md                ← this file
├── supabase/
│   └── schema.sql          ← run this in Supabase SQL editor (step 4)
└── workout-logger-standalone/   ← standalones you build go in folders like this
    └── index.html
```

That's the whole system.
