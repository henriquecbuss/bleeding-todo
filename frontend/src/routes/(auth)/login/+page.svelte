<script>
	import { api } from '$lib/api/fetcher';
	import Button from '$lib/components/button.svelte';
	import Input from '$lib/components/input.svelte';
	import { authStore } from '$lib/stores/auth.store';

	let emailOrUsername = '';
	let password = '';

	const signIn = async () => {
		const result = await api('/auth/sign-in', 'POST', { emailOrUsername, rawPassword: password });

		if (result.isOk()) {
			authStore.set(result.value.jwt);
			// TODO: Redirect user
		} else {
			// TODO: Show Toast
			console.error(result.error);
		}
	};
</script>

<div class="my-auto">
	<h1 class="text-3xl font-medium text-center">Welcome back</h1>

	<div class="mx-auto w-full max-w-md px-4 mt-8">
		<div class="bg-white border shadow-sm text-gray-900 rounded-lg p-8">
			<form on:submit|preventDefault={signIn}>
				<Input
					label="E-mail"
					inputProps={{ inputmode: 'email', autocomplete: 'email', required: true }}
					bind:value={emailOrUsername}
				/>

				<Input
					label="Password"
					inputProps={{ type: 'password', required: true, autocomplete: 'current-password' }}
					className="mt-6"
					bind:value={password}
				/>

				<Button className="w-full mt-8">Login</Button>
			</form>
		</div>
	</div>
</div>
