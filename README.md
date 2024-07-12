# Blog App

This is a blog application that allows users to authenticate and manage their blog posts. It is built following clean architecture principles using Flutter, Bloc, and Supabase.

## Getting Started

1. Create a new [Supabase](https://supabase.com/) project.

2. Configure your Supabase project:

   - In the SQL Editor, run the following scripts to set up the database:

     ```sql
     -- Create a table for public profiles
     create table profiles (
     id uuid references auth.users not null primary key,
     updated_at timestamp with time zone,
     name text,
     constraint name_length check (char_length(name) >= 3)
     );

     -- Set up Row Level Security (RLS)
     alter table profiles enable row level security;
     create policy "Public profiles are viewable by everyone." on profiles
     for select using (true);
     create policy "Users can insert their own profile." on profiles
     for insert with check ((select auth.uid()) = id);
     create policy "Users can update own profile." on profiles
     for update using ((select auth.uid()) = id);

     -- Trigger for creating a profile entry on user signup
     create function public.handle_new_user()
     returns trigger as $$
     begin
     insert into public.profiles (id, name)
     values (new.id, new.raw_user_meta_data->>'name');
     return new;
     end;
     $$ language plpgsql security definer;
     create trigger on_auth_user_created
     after insert on auth.users
     for each row execute procedure public.handle_new_user();
     ```

     ```sql
     -- Create a table for public blogs
     create table blogs (
     id uuid not null primary key,
     updated_at timestamp with time zone,
     poster_id uuid not null,
     title text not null,
     content text not null,
     image_url text,
     topics text array,
     foreign key (poster_id) references public.profiles(id));

     -- Set up Row Level Security (RLS)
     alter table blogs enable row level security;
     create policy "Public blogs are viewable by everyone." on blogs
     for select using (true);
     create policy "Users can insert their own blogs." on blogs
     for insert with check ((select auth.uid()) = poster_id);
         create policy "Users can update own blogs." on blogs
     for update using ((select auth.uid()) = poster_id);

     -- Set up Storage
     insert into storage.buckets (id, name)
     values ('blog_images', 'blog_images');

     -- Set up access controls for storage
     create policy "Blog images are publicly accessible." on storage.objects
     for select using (bucket_id = 'blog_images');
     create policy "Anyone can upload a blog image." on storage.objects
     for insert with check (bucket_id = 'blog_images');
     create policy "Anyone can update their own blog image." on storage.objects
     for update using ((select auth.uid()) = owner) with check (bucket_id = 'blog_images');
     ```

3. Add your Supabase URL and API key to the app:

   - Create a file at `/lib/core/secrets/app_secrets.dart` and add your Supabase URL and API key:

     ```dart
     class AppSecrets {
     static const supabaseUrl = 'YOUR_SUPABASE_URL';
     static const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
     }
     ```

4. Run the app:

   ```bash
   flutter run
   ```
