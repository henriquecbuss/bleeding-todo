import tippy, { type Instance } from 'tippy.js';

export const tooltip = (
	node: HTMLElement,
	options: {
		requireOverflow?: boolean;
		innerQuerySelector?: keyof HTMLElementTagNameMap;
		content: string;
	}
) => {
	let tooltipInstance: Instance | null = null;

	const targetNode = options.innerQuerySelector
		? node.querySelector(options.innerQuerySelector)
		: node;

	const handlePointerEnter = () => {
		if (!targetNode) {
			return;
		}

		const isOverflowing = targetNode.scrollHeight > targetNode.offsetHeight;

		if (!options.requireOverflow || isOverflowing) {
			tooltipInstance = tippy(node, {
				content: options.content,
				theme: 'custom'
			});
		}
	};

	node.addEventListener('pointerenter', handlePointerEnter);

	return {
		destroy() {
			node.removeEventListener('pointerenter', handlePointerEnter);
			tooltipInstance?.destroy();
		}
	};
};
