import type { AppRouter } from '@backend/index';
import { TRPCUntypedClient, createTRPCClientProxy, createWSClient, wsLink } from '@trpc/client';

export const clientId = Date.now();

export default function createClient() {
    const ws = createWSClient({ url: `${import.meta.env.VITE_TRPC ?? 'ws://localhost:3000/trpc'}?id=${clientId}` });
    return createTRPCClientProxy<AppRouter>(new TRPCUntypedClient({
        links: [
            wsLink({
                client: ws
            })
        ]
    }));
}
