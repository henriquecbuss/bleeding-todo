export const cssVariables = (node: HTMLElement, variables: Record<string, string>) => {
	setCssVariables(node, variables);

	return {
		update: (variables: Record<string, string>) => {
			setCssVariables(node, variables);
		}
	};
};
const setCssVariables = (node: HTMLElement, variables: Record<string, string>) => {
	for (const name in variables) {
		node.style.setProperty(`--${name}`, variables[name]);
	}
};
