<script lang="ts">
	import { cn } from '$lib/utils';

	export let className: string = '';
</script>

<button
	class={cn(
		'bg-gray-800 hover:bg-gray-700 active:bg-gray-900 text-white rounded-lg py-4 px-3',
		className
	)}
>
	<slot />
</button>
