<script>
	import { api } from '$lib/api/fetcher';
	import Button from '$lib/components/button.svelte';
	import Input from '$lib/components/input.svelte';
	import { authStore } from '$lib/stores/auth.store';
	import { toast } from 'svelte-french-toast';

	let email = '';
	let username = '';
	let password = '';

	const signUp = async () => {
		const result = await api('/auth/sign-up', 'POST', { email, username, rawPassword: password });

		if (result.isOk()) {
			authStore.login(result.value.jwt);
		} else {
			toast.error(result.error.error);
		}
	};
</script>

<div class="my-auto">
	<h1 class="text-3xl font-medium text-center">Create your account</h1>

	<div class="mx-auto w-full max-w-md px-4 mt-8">
		<div class="bg-white border shadow-sm text-gray-900 rounded-lg p-8">
			<form on:submit|preventDefault={signUp}>
				<Input
					label="E-mail"
					inputProps={{ type: 'email', inputmode: 'email', autocomplete: 'email', required: true }}
					bind:value={email}
				/>

				<Input
					label="Username"
					inputProps={{ required: true, autocomplete: 'username' }}
					className="mt-6"
					bind:value={username}
				/>

				<Input
					label="Password"
					inputProps={{ type: 'password', required: true, autocomplete: 'new-password' }}
					className="mt-6"
					bind:value={password}
				/>

				<Button className="w-full mt-8">Create Account</Button>
			</form>
		</div>
	</div>
</div>
