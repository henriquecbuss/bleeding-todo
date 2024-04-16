import type { Call, ComposeLeft, Objects, Pipe, Strings, Unions, _ } from 'hotscript';
import { z } from 'zod';
import { env } from '$lib/env/public';
import { getAuthJwt } from '$lib/stores/auth.store';
import { authSchema } from './auth';
import { Result, Ok, Err } from 'ts-results-es';

const apiSchema = {
	auth: authSchema
} satisfies ApiSchemaItem;

type HttpMethod = 'GET' | 'POST';

type MethodSchema = { input: z.AnyZodObject; output: z.AnyZodObject; error: z.AnyZodObject };

type LeafApiSchemaItem = {
	route: string;
	GET?: MethodSchema;
	POST?: MethodSchema;
};

type ApiSchemaItem = LeafApiSchemaItem | { [k: string]: ApiSchemaItem };

type ApiReturn<R extends Route, M extends MethodsForRoute<R>> = Result<
	z.output<NonNullable<OutputForRoute<R, M>>>,
	z.output<NonNullable<ErrorForRoute<R, M>>>
>;

export const api = async <R extends Route, M extends MethodsForRoute<R>>(
	route: R,
	method: M,
	input: z.input<NonNullable<InputForRoute<R, M>>>
): Promise<ApiReturn<R, M>> => {
	const url = `${env.PUBLIC_BACKEND_URL}${route}`;

	const routePath = route.slice(1).replaceAll('/', '.') as Call<Objects.AllPaths, typeof apiSchema>;

	const routeObject: LeafApiSchemaItem = getPath(apiSchema, routePath);

	const methodObject = routeObject[method];

	if (!methodObject) {
		throw new Error(`Method ${method} not supported for route ${route}`);
	}

	const parsedInput = methodObject.input.parse(input);

	const jwt = getAuthJwt();

	const result = await fetch(url, {
		method,
		headers: {
			'Content-Type': 'application/json',
			...(jwt && { Authorization: `Bearer ${jwt}` })
		},
		body: JSON.stringify(parsedInput)
	});

	const json = await result.json();

	if (result.ok) {
		const output = methodObject.output.parse(json);

		return Ok(output) as ApiReturn<R, M>;
	}

	const parsedError = methodObject.error.parse(json);

	return Err(parsedError) as ApiReturn<R, M>;
};

type Route = `/${Paths<typeof apiSchema, UnionToTuple<keyof typeof apiSchema>>}`;

type MethodsForRoute<R extends string> = Pipe<
	R,
	[GetRouteObject, Objects.Keys, Unions.Extract<HttpMethod>]
>;

type InputForRoute<R extends string, M extends MethodsForRoute<R>> = Pipe<
	R,
	[GetRouteObject, Objects.Get<M>, Objects.Get<'input'>]
>;

type OutputForRoute<R extends string, M extends MethodsForRoute<R>> = Pipe<
	R,
	[GetRouteObject, Objects.Get<M>, Objects.Get<'output'>]
>;

type ErrorForRoute<R extends string, M extends MethodsForRoute<R>> = Pipe<
	R,
	[GetRouteObject, Objects.Get<M>, Objects.Get<'error'>]
>;

const getPath = <TObj extends Record<string, unknown>, TPath extends Call<Objects.AllPaths, TObj>>(
	object: TObj,
	path: TPath
): Call<Objects.Get<TPath>, TObj> => {
	// @ts-expect-error Types actually guarantee this is correct
	return path.split('.').reduce((acc, segment) => acc[segment], object);
};

type Paths<T, Keys> = Keys extends [infer First extends keyof T & string, ...infer Rest]
	? T[First] extends LeafApiSchemaItem
		? First | Paths<T, Rest>
		: `${First}/${Paths<T[First], UnionToTuple<keyof T[First]>>}` | Paths<T, Rest>
	: never;

type GetRouteObject = ComposeLeft<
	[Strings.TrimLeft<'/'>, Strings.Replace<'/', '.'>, Objects.Get<_, typeof apiSchema>]
>;

type UnionToTuple<T> = Call<Unions.ToTuple, T>;
