///
///  Created by George Cox on 1/22/20.
///

import Foundation
import Nimble
import Quick
#if SWIFT_PACKAGE
import JobQueueCore
#endif

@testable import JobQueue

class JobQueueProcessorsTests: QuickSpec {
  override func spec() {
    describe("activeProcessorsByID") {
      var processors: JobQueueProcessors!

      beforeEach {
        processors = JobQueueProcessors()
        processors.configurations[Processor1.jobType] = JobProcessorConfiguration(Processor1.self, concurrency: 5)
        processors.activeProcessor(for: try! Job(Processor1.self, id: "0", queueName: "", payload: "test"))
        processors.activeProcessor(for: try! Job(Processor1.self, id: "1", queueName: "", payload: "test"))
        processors.activeProcessor(for: try! Job(Processor1.self, id: "2", queueName: "", payload: "test"))
      }
      it("should exclude the expected ids") {
        expect(processors.activeProcessorsByID(excluding: ["1"]).map { $0.key }.sorted())
          .to(equal(["0", "2"]))
      }
    }

    describe("remove") {
      var processors: JobQueueProcessors!

      beforeEach {
        processors = JobQueueProcessors()
        processors.configurations[Processor1.jobType] = JobProcessorConfiguration(Processor1.self, concurrency: 5)
        processors.activeProcessor(for: try! Job(Processor1.self, id: "0", queueName: "", payload: "test"))
        processors.activeProcessor(for: try! Job(Processor1.self, id: "1", queueName: "", payload: "test"))
        processors.activeProcessor(for: try! Job(Processor1.self, id: "2", queueName: "", payload: "test"))
      }

      it("should remove the correct processors") {
        processors.remove(processors: ["1", "3"])
        expect(processors.active[Processor1.jobType]!.keys.map { $0 }.sorted())
          .to(equal(["0", "2"]))
      }
    }

    describe("activeProcessor") {
      var processors: JobQueueProcessors!
      var testJobs: [Job]!

      beforeEach {
        processors = JobQueueProcessors()
        testJobs = [
          try! Job(Processor1.self, id: "0", queueName: "", payload: "test"),
          try! Job(Processor1.self, id: "1", queueName: "", payload: "test"),
          try! Job(Processor1.self, id: "2", queueName: "", payload: "test")
        ]
      }

      context("when no configuration exists for the job") {
        it("should not return a processor") {
          expect(processors.activeProcessor(for: testJobs[0]))
            .to(beNil())
        }
      }

      context("when a configuration exists for the job") {
        beforeEach {
          processors.configurations[Processor1.jobType] =
            .init(Processor1.self, concurrency: 1)
        }
        it("should return a processor") {
          expect(processors.activeProcessor(for: testJobs[0]))
            .notTo(beNil())
        }

        context("when a processor already exists") {
          it("should return the same processor") {
            let processor1 = processors.activeProcessor(for: testJobs[0]) as! Processor1
            let processor2 = processors.activeProcessor(for: testJobs[0]) as! Processor1

            expect(processor1).to(equal(processor2))
          }
        }

        context("when a processor does not already exist") {
          context("when the concurrency limit has not been reached") {
            beforeEach {
              processors.configurations[Processor1.jobType] =
                .init(Processor1.self, concurrency: 2)
            }

            it("should return new processors") {
              let processor1 = processors.activeProcessor(for: testJobs[0])
              let processor2 = processors.activeProcessor(for: testJobs[1])
              expect(processor1).notTo(beNil())
              expect(processor2).notTo(beNil())

              guard
                let processor1Typed = processor1 as? Processor1,
                let processor2Typed = processor2 as? Processor1 else {
                  fail("Did not return the correct processor types")
                  return
              }
              expect(processor1Typed).notTo(equal(processor2Typed))
            }

            it("should return a new processor") {
              let processor1 = processors.activeProcessor(for: testJobs[0])
              let processor2 = processors.activeProcessor(for: testJobs[1])
              expect(processor1).notTo(beNil())
              expect(processor2).notTo(beNil())
            }
          }

          context("when the concurrency limit has been reached") {
            beforeEach {
              processors.configurations[Processor1.jobType] =
                .init(Processor1.self, concurrency: 2)
              processors.activeProcessor(for: testJobs[0])
              processors.activeProcessor(for: testJobs[1])
            }

            it("should not return a new processor") {
              expect(processors.activeProcessor(for: testJobs[2])).to(beNil())
            }
          }
        }
      }
    }
  }
}
