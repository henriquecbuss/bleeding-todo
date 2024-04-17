<script>
	import '../app.css';
	import 'tippy.js/dist/tippy.css';
	import 'tippy.js/dist/border.css';

	import { Toaster } from 'svelte-french-toast';
</script>

<slot />

<Toaster />

<style>
	:global(html, body) {
		height: 100%;
	}

	:global(.tippy-box[data-theme~='custom']) {
		background-color: theme('colors.gray.700');
		color: theme('colors.white');
		border: 1px solid theme('colors.gray.600');

		font-size: theme('fontSize.xs');
	}

	:global(.tippy-box[data-theme~='custom'][data-placement^='top'] > .tippy-arrow::before) {
		border-top-color: theme('colors.gray.700');
	}

	:global(.tippy-box[data-theme~='custom'][data-placement^='bottom'] > .tippy-arrow::before) {
		border-bottom-color: theme('colors.gray.700');
	}

	:global(.tippy-box[data-theme~='custom'][data-placement^='left'] > .tippy-arrow::before) {
		border-left-color: theme('colors.gray.700');
	}

	:global(.tippy-box[data-theme~='custom'][data-placement^='right'] > .tippy-arrow::before) {
		border-right-color: theme('colors.gray.700');
	}
</style>
