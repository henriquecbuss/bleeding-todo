<script>
	import Button from '$lib/components/button.svelte';
	import Input from '$lib/components/input.svelte';

	let email = '';
	let password = '';
</script>

<div class="my-auto">
	<h1 class="text-3xl font-medium text-center">Welcome back</h1>

	<div class="mx-auto w-full max-w-md px-4 mt-8">
		<div class="bg-white border shadow-sm text-gray-900 rounded-lg p-8">
			<form
				on:submit|preventDefault={() => {
					console.log({ email, password });
				}}
			>
				<Input
					label="E-mail"
					inputProps={{ type: 'email', inputmode: 'email', autocomplete: 'email', required: true }}
					bind:value={email}
				/>

				<Input
					label="Password"
					inputProps={{ type: 'password', required: true, autocomplete: 'new-password' }}
					className="mt-6"
					bind:value={password}
				/>

				<Button className="w-full mt-8">Login</Button>
			</form>
		</div>
	</div>
</div>
