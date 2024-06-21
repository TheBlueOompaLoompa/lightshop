import type { AppRouter } from '@backend/index';
import { TRPCUntypedClient, createTRPCClientProxy, createWSClient, wsLink } from '@trpc/client';

export default function createClient() {
    const ws = createWSClient({ url: import.meta.env.VITE_TRPC });
    return createTRPCClientProxy<AppRouter>(new TRPCUntypedClient({
        links: [
            wsLink({
                client: ws
            })
        ]
    }));
}
