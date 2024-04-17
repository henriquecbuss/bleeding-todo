<script lang="ts">
	import RedirectGate from '$lib/components/redirect-gate.svelte';
	import { authStore } from '$lib/stores/auth.store';
	import {
		Dialog,
		DialogOverlay,
		Menu,
		MenuButton,
		Transition,
		MenuItems,
		MenuItem,
		TransitionChild
	} from '@rgossiaux/svelte-headlessui';
	import { Icon, Bars3, XMark, User } from 'svelte-hero-icons';
	import Sidebar from './sidebar.svelte';
	import { cn } from '$lib/utils';

	let dialogIsOpen = false;
</script>

<RedirectGate condition={!!$authStore} redirect="/login">
	<div class="h-full flex flex-col">
		<nav class="bg-gray-800 md:hidden">
			<div class="mx-auto max-w-7xl px-4">
				<div class="relative flex h-16 items-center justify-between">
					<div class="flex items-center gap-4">
						<button
							class="relative inline-flex items-center justify-center rounded-md p-2 text-gray-400 hover:bg-gray-700 hover:text-white focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-white"
							on:click={() => {
								dialogIsOpen = true;
							}}
						>
							<span class="absolute -inset-0.5" />
							<span class="sr-only">Open navigation menu</span>
							<Icon src={Bars3} class="block h-6 w-6" aria-hidden="true" />
						</button>
					</div>

					<Menu as="div" class="relative ml-3">
						<div>
							<MenuButton
								class="relative flex rounded-full bg-gray-800 text-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white focus-visible:ring-offset-2 focus-visible:ring-offset-gray-800"
							>
								<span class="absolute -inset-1.5" />
								<span class="sr-only">Open user menu</span>
								<div class="h-8 w-8 rounded-full border border-gray-300 p-1.5">
									<Icon src={User} class="text-gray-300" />
								</div>
							</MenuButton>
						</div>
						<Transition
							enter="transition ease-out duration-100"
							enterFrom="transform opacity-0 scale-95"
							enterTo="transform opacity-100 scale-100"
							leave="transition ease-in duration-75"
							leaveFrom="transform opacity-100 scale-100"
							leaveTo="transform opacity-0 scale-95"
						>
							<MenuItems
								class="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus-visible:outline-none"
							>
								<MenuItem let:active>
									<button
										on:click={() => authStore.logout()}
										class={cn('block w-full text-left px-4 py-2 text-sm text-gray-700', {
											'bg-gray-100': active
										})}
									>
										Sign out
									</button>
								</MenuItem>
							</MenuItems>
						</Transition>
					</Menu>
				</div>
			</div>
		</nav>

		<Transition
			show={dialogIsOpen}
			enter="transition duration-100 ease-out"
			enterFrom="transform scale-95 opacity-0"
			enterTo="transform scale-100 opacity-100"
			leave="transition duration-75 ease-out"
			leaveFrom="transform scale-100 opacity-100"
			leaveTo="transform scale-95 opacity-0"
		>
			<Dialog
				class="md:hidden shrink-0"
				on:close={() => {
					dialogIsOpen = false;
				}}
			>
				<TransitionChild
					enter="ease-out duration-300"
					enterFrom="opacity-0"
					enterTo="opacity-100"
					leave="ease-in duration-200"
					leaveFrom="opacity-100"
					leaveTo="opacity-0"
				>
					<DialogOverlay class="fixed inset-0 bg-black/30" />
				</TransitionChild>

				<div class="absolute left-0 top-0 bottom-0 flex">
					<TransitionChild
						enter="ease-out duration-300"
						enterFrom="-translate-x-full"
						enterTo="translate-x-0"
						leave="ease-in duration-200"
						leaveFrom="translate-x-0"
						leaveTo="-translate-x-full"
					>
						<div class="flex h-full">
							<Sidebar />

							<div class="h-16 flex items-center ml-2">
								<button
									class="relative rounded-full p-2 text-white focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-white"
									on:click={() => {
										dialogIsOpen = false;
									}}
								>
									<span class="absolute -inset-0.5" />
									<span class="sr-only">Close navigation menu</span>
									<Icon src={XMark} class="block h-6 w-6" aria-hidden="true" />
								</button>
							</div>
						</div>
					</TransitionChild>
				</div>
			</Dialog>
		</Transition>

		<div class="flex grow md:h-screen">
			<Sidebar className="hidden md:flex" />

			<h1>App Layout</h1>
			<slot />
		</div>
	</div>
</RedirectGate>
