//
//  Created by Kurlovich Vitali on 11/5/26.
//

actor AsyncSemaphore {
    private var available: Int
    private var waiters: [CheckedContinuation<Void, Never>] = []

    init(limit: Int) {
        available = limit
    }

    func wait() async {
        if available > 0 {
            available -= 1; return
        }
        await withCheckedContinuation { waiters.append($0) }
    }

    func signal() {
        if waiters.isEmpty {
            available += 1
        } else {
            waiters.removeFirst().resume()
        }
    }

    func run<T: Sendable>(_ op: @Sendable () async throws -> T) async rethrows -> T {
        await wait()
        defer { signal() } // signal() is actor-isolated; this works because we're inside the actor
        return try await op()
    }
}
