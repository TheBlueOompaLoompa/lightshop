export default class ZodWorker<SchemaType> extends Worker {
    msg(msg: SchemaType, transfer: Bun.Transferable[] = []) {
        super.postMessage(msg, transfer);
    }
}
