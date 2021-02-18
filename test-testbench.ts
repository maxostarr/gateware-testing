import { describe, test } from "./node_modules/gateware-ts/dist/testware/index";
import {
  GWModule,
  Signal,
  Not,
  edges,
  Edge,
  assert,
  display,
  HIGH,
  LOW,
  If,
  CodeGenerator,
  microseconds,
  nanoseconds,
  Constant,
} from "./node_modules/gateware-ts/dist/src/index";

const COUNTER_BITS = 8;

export class Test extends GWModule {
  clk = this.input(Signal());
  trigger = this.input(Signal());
  counter = this.input(Signal(COUNTER_BITS));
  out = this.output(Signal());

  A = this.internal(Signal(4));
  B = this.internal(Signal(4));
  C = this.internal(Signal(5));
  O = this.internal(Signal());

  describe() {
    const pulse = (n: number = 1) => edges(n, Edge.Positive, this.clk);

    this.simulation.everyTimescale(1, [
      this.clk["="](Not(this.clk)),
      If(this.clk["=="](1), [this.counter["="](this.counter["+"](1))]),
    ]);

    this.syncBlock(this.clk, Edge.Positive, [this.C["="](this.A["+"](this.B))]);

    this.simulation.run(
      describe("Testing", [
        test("Add should make sense", (expect) => [
          this.A["="](Constant(4, 0x7)),
          this.B["="](Constant(4, 0x1)),
          this.C["="](this.A["+"](this.B)),
          this.O["="](
            this.A.bit(3)
              ["=="](this.B.bit(3))
              ["&&"](this.C.bit(3)["!="](this.B.bit(3))),
          ),
          pulse(1),
          display(this.C),
          expect(this.C["=="](Constant(5, 0b1111 + 0b1111)), ""),
        ]),
      ]),
    );
  }
}

const testBench = new Test();
const tbCg = new CodeGenerator(testBench, {
  simulation: {
    enabled: true,
    timescale: [microseconds(1), nanoseconds(10)],
  },
});

tbCg.runSimulation("test", "test.vcd");
tbCg.writeVerilogToFile("test");
