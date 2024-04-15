<script lang="ts">
	import Navbar from '$lib/components/navbar.svelte';
	import Gleam from '$lib/icons/gleam.svelte';
	import Svelte from '$lib/icons/svelte.svelte';
	import Tailwindcss from '$lib/icons/tailwindcss.svelte';
	import Typescript from '$lib/icons/typescript.svelte';
	import { ArrowDownCircle, CheckBadge, Icon } from 'svelte-hero-icons';

	const features = [
		{
			name: 'Gleam',
			description:
				"Everything I've wanted since trying out Elixir: strong, static types on top of OTP",
			href: 'https://gleam.run',
			imgComponent: Gleam
		},
		{
			name: 'Svelte',
			description: 'Yet another JS framework. But good this time. Maybe. Who knows?',
			href: 'https://svelte.dev',
			imgComponent: Svelte
		},
		{
			name: 'TailwindCSS',
			description: "I just used this to steal components. It's not stealing if it's productive",
			href: 'https://tailwindcss.com',
			imgComponent: Tailwindcss
		},
		{
			name: 'Typescript',
			description: 'Type-level programming is cool. Types go brrr',
			href: 'https://typescriptlang.org',
			imgComponent: Typescript
		}
	];
</script>

<Navbar />

<main
	style:background-image={"url(\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='100' height='100' viewBox='0 0 100 100'%3E%3Cg fill-rule='evenodd'%3E%3Cg fill='%23d1d5db' fill-opacity='0.4'%3E%3Cpath opacity='.5' d='M96 95h4v1h-4v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4h-9v4h-1v-4H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15v-9H0v-1h15V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h9V0h1v15h4v1h-4v9h4v1h-4v9h4v1h-4v9h4v1h-4v9h4v1h-4v9h4v1h-4v9h4v1h-4v9h4v1h-4v9zm-1 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-9-10h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm9-10v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-9-10h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm9-10v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-9-10h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm9-10v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-10 0v-9h-9v9h9zm-9-10h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9zm10 0h9v-9h-9v9z'/%3E%3Cpath d='M6 5V0H5v5H0v1h5v94h1V6h94V5H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E\")"}
	class="relative pt-44 min-h-[80svh] after:h-24 after:w-full after:bottom-0 after:absolute after:bg-gradient-to-b after:from-transparent after:to-white"
>
	<h1 class="text-5xl text-center font-bold text-gray-800">Bleeding TODO</h1>

	<p class="text-lg text-center mt-6 text-gray-600">
		A TODO list built with <span
			class="text-transparent bg-clip-text bg-gradient-to-br from-red-500 to-violet-600"
			>bleeding edge</span
		> tech
	</p>

	<a href="#features" class="flex items-center justify-center w-12 h-12 mx-auto mt-16">
		<Icon src={ArrowDownCircle} class="w-8 h-8 text-gray-800" />
	</a>
</main>

<section class="bg-white" id="features">
	<div
		class="mx-auto grid max-w-2xl grid-cols-1 items-center gap-x-8 gap-y-16 px-4 py-24 sm:px-6 lg:max-w-7xl lg:grid-cols-2 lg:px-8"
	>
		<div>
			<div class="w-max">
				<h2 class="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
					The
					<span class="font-bold text-violet-600">bleeding</span> bit
				</h2>
				<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1418 125" fill="#7C3AED"
					><path
						d="M1412.29 72.17c-11.04-5.78-20.07-14.33-85.46-25.24-22.37-3.63-44.69-7.56-67.07-11.04-167.11-22.06-181.65-21.24-304.94-30.56C888.78 1.39 822.57 1.1 756.44 0c-46.63-.11-93.27 1.56-139.89 2.5C365.5 13.55 452.86 7.68 277.94 23.15 202.57 33.32 127.38 45.01 52.07 55.69c-11.23 2.41-22.63 4.17-33.71 7.22C6.1 66.33 5.64 66.19 3.89 67.79c-7.99 5.78-2.98 20.14 8.72 17.5 33.99-9.47 32.28-8.57 178.06-29.66 4.26 4.48 7.29 3.38 18.42 3.11 13.19-.32 26.38-.53 39.56-1.12 53.51-3.81 106.88-9.62 160.36-13.95 18.41-1.3 36.8-3.12 55.21-4.7 23.21-1.16 46.43-2.29 69.65-3.4 120.28-2.16 85.46-3.13 234.65-1.52 23.42.99 1.57-.18 125.72 6.9 96.61 8.88 200.92 27.94 295.42 46.12 40.87 7.91 116.67 23.2 156.31 36.78 3.81 1.05 8.28-.27 10.51-3.58 3.17-3.72 2.66-9.7-.78-13.13-3.25-3.12-8.14-3.44-12.18-5.08-17.89-5.85-44.19-12.09-63.67-16.56l26.16 3.28c23.02 3.13 46.28 3.92 69.34 6.75 10.8.96 25.43 1.81 34.34-4.39 2.26-1.54 4.86-2.75 6.21-5.27 2.76-4.59 1.13-11.06-3.59-13.68ZM925.4 23.77c37.64 1.4 153.99 10.85 196.64 14.94 45.95 5.51 91.89 11.03 137.76 17.19 24.25 4.77 74.13 11.21 101.72 18.14-11.87-1.15-23.77-1.97-35.65-3.06-133.46-15.9-266.8-33.02-400.47-47.21Z"
					></path></svg
				>
			</div>
			<p class="mt-4 text-gray-500">
				This is just a TODO list app. Nothing special. What makes it cool is the tech used to build
				it. That makes it cool... right?
			</p>
			<p class="text-gray-400 text-sm mt-2">
				Functional programming, type safety and the millionth frontend framework
			</p>

			<dl class="mt-16 grid grid-cols-1 gap-x-6 gap-y-10 sm:grid-cols-2 sm:gap-y-16 lg:gap-x-8">
				{#each features as feature (feature.name)}
					<div class="border-t border-gray-200 pt-4">
						<dt class="font-medium text-gray-900 hover:underline w-max">
							<a href={feature.href}>
								{feature.name}
							</a>
						</dt>
						<dd class="mt-2 text-sm text-gray-500">{feature.description}</dd>
					</div>
				{/each}
			</dl>
		</div>
		<div class="grid grid-cols-2 grid-rows-2 gap-4 sm:gap-6 lg:gap-8 min-h-full">
			{#each features as feature (feature.name)}
				<a
					href={feature.href}
					class="rounded-lg bg-gray-100 p-8 flex items-center justify-center group"
				>
					<svelte:component
						this={feature.imgComponent}
						className="group-even:group-hover:rotate-12 group-odd:group-hover:-rotate-12 transition-transform"
					/>
				</a>
			{/each}
		</div>
	</div>
</section>

<footer class="bg-gray-800 text-gray-200 py-12">
	<div
		class="flex flex-col sm:items-center gap-8 max-w-2xl px-4 sm:px-6 sm:flex-row lg:max-w-7xl lg:px-8"
	>
		<Icon src={CheckBadge} class="h-8 w-8 text-white" alt="Bleeding TODO" />

		<p>There's really not much else here. I mean, it's just a simple TODO list</p>
	</div>
</footer>

<style>
	:global(html) {
		scroll-behavior: smooth;
	}
</style>
