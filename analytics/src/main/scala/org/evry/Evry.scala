package org.evry

object Evry extends App {
  import cc.factorie._
  import cc.factorie.app.nlp.{ Document, Token }
  import cc.factorie.app.chain.ChainModel
  import cc.factorie.app.nlp.segment.{ DeterministicSentenceSegmenter, DeterministicTokenizer }
  import cc.factorie.optimize.Trainer
  import cc.factorie.variable.{ LabeledCategoricalVariable, BinaryFeatureVectorVariable, CategoricalVectorDomain, CategoricalDomain }
  import cc.factorie.infer.InferByBPChain
  implicit val random = new scala.util.Random(0)

  val c = new CategoricalDomain[String]()

  for (feature <- (0 until 1000).par) {
    // calling .index on a domain will add the category to the domain if it's not present,
    // and return its index. It is fine to do this from many threads at once.
    c.index(feature.toString)
  }

object LabelDomain extends CategoricalDomain[String]
  class Label(val token: Token, s: String) extends LabeledCategoricalVariable(s) {
    def domain = LabelDomain
  }
  object FeaturesDomain extends CategoricalVectorDomain[String]
  class Features(val token: Token) extends BinaryFeatureVectorVariable[String] {
    def domain = FeaturesDomain
  }
  object model extends ChainModel[Label, Features, Token](
    LabelDomain,
    FeaturesDomain,
    l => l.token.attr[Features],
    l => l.token,
    t => t.attr[Label])
  val document = new Document("The quick brown fox jumped over the lazy dog.")
  DeterministicTokenizer.process(document)
  DeterministicSentenceSegmenter.process(document)
  document.tokens.foreach(t => t.attr += new Label(t, "A"))
  LabelDomain.index("B")
  document.tokens.foreach(t => {
    val features = t.attr += new Features(t)
    features += "W=" + t.string.toLowerCase
    features += "IsCapitalized=" + t.string(0).isUpper.toString
  })
  val example = new optimize.LikelihoodExample(document.tokens.toSeq.map(_.attr[Label]), model, InferByBPChain)

  Trainer.batchTrain(model.parameters, Seq(example), nThreads = 2)

  import cc.factorie.util.CmdOptions
  object opts extends CmdOptions {
    val dummy1 = new CmdOption("dummy1", "A", "STRING", "Doesn't mean anything")
    val dummy2 = new CmdOption("dummy2", 0.1, "DOUBLE", "Doesn't mean much either")
  }

  import cc.factorie.util.{ HyperParameter, SampleFromSeq, UniformDoubleSampler }
  val d1 = new HyperParameter(opts.dummy1, new SampleFromSeq(Seq("A", "B", "C")))
  val d2 = new HyperParameter(opts.dummy2, new UniformDoubleSampler(0, 1))

  import scala.concurrent.ExecutionContext.Implicits.global
  import scala.concurrent.Future
  val executor1 = (a: Array[String]) => Future { 1.0 }

  val hyp = new cc.factorie.util.HyperParameterSearcher(opts, Seq(d1, d2), executor1, numTrials = 10, numToFinish = 5, secondsToSleep = 1)
  val optimizeArgs = hyp.optimize()
  assertStringEquals(optimizeArgs.length, "2")

}




object Learning extends App {
  import cc.factorie._
  import variable._
  import cc.factorie.app.nlp._
  import cc.factorie.app.chain._
  import cc.factorie.optimize.{ SynchronizedOptimizerOnlineTrainer, Trainer, SampleRankTrainer }
  import cc.factorie.infer.{ GibbsSampler, InferByBPChain }

  implicit val random = new scala.util.Random(0)

  object LabelDomain extends CategoricalDomain[String]
  class Label(val token: Token, s: String) extends LabeledCategoricalVariable(s) {
    def domain = LabelDomain
  }
  object FeaturesDomain extends CategoricalVectorDomain[String]
  class Features(val token: Token) extends BinaryFeatureVectorVariable[String] {
    def domain = FeaturesDomain
  }

object model extends ChainModel[Label, Features, Token](
    LabelDomain,
    FeaturesDomain,
    l => l.token.attr[Features],
    l => l.token,
    t => t.attr[Label])

  // The Document class implements documents as sequences of sentences and tokens.
  val document = new Document("The quick brown fox jumped over the lazy dog.")
  val tokenizer = new app.nlp.segment.DeterministicTokenizer
  tokenizer.process(document)
  val segmenter = new app.nlp.segment.DeterministicSentenceSegmenter
  segmenter.process(document)
  assertStringEquals(document.tokenCount, "10")
  assertStringEquals(document.sentenceCount, "1")

  // Let's assign all tokens the same label for the sake of simplicity
  document.tokens.foreach(t => t.attr += new Label(t, "A"))
  // Let's also have another possible Label value to make things interesting
  LabelDomain.index("B")
  // Let's also initialize features for all tokens
  document.tokens.foreach(t => {
    val features = t.attr += new Features(t)
    // One feature for the token's string value
    features += "W=" + t.string.toLowerCase
    // And one feature for its capitalization
    features += "IsCapitalized=" + t.string(0).isUpper.toString
  })

  val summary = InferByBPChain.infer(document.tokens.toSeq.map(_.attr[Label]), model)
  assertStringEquals(summary.logZ, "6.931471805599453")
  assertStringEquals(summary.marginal(document.tokens.head.attr[Label]).proportions, 
                     "Proportions(0.49999999999999994,0.49999999999999994)")

  val example = new optimize.LikelihoodExample(document.tokens.toSeq.map(_.attr[Label]), model, InferByBPChain)

 val optimizer0 = new optimize.AdaGrad()

  Trainer.onlineTrain(model.parameters, Seq(example), optimizer = optimizer0)

  // Factorie also supports batch learning. Note that regularization is built into the optimizer
  val optimizer1 = new optimize.LBFGS with optimize.L2Regularization
  optimizer1.variance = 10000.0
  Trainer.batchTrain(model.parameters, Seq(example), optimizer = optimizer1)

 val trainer = new SynchronizedOptimizerOnlineTrainer(model.parameters, optimizer0)

trainer.trainFromExamples(Seq(example))


  // Now we can run inference and see that we have learned
  val summary2 = InferByBPChain(document.tokens.map(_.attr[Label]).toIndexedSeq, model)
  assertStringEquals(summary2.logZ, "48.63607808729122")
  assertStringEquals(summary2.marginal(document.tokens.head.attr[Label]).proportions, 
                     "Proportions(0.9999308678897892,6.913211020966629E-5)")

  val sampler = new GibbsSampler(model, HammingObjective)
  val sampleRankExamples = document.tokens.toSeq.map(t => new optimize.SampleRankExample(t.attr[Label], sampler))
  Trainer.onlineTrain(model.parameters, sampleRankExamples, optimizer = optimizer0)
  // SampleRank comes with its own trainer, however, for ease of use
  val trainer2 = new SampleRankTrainer(model.parameters, sampler, optimizer0)
  trainer2.processContexts(document.tokens.toSeq.map(_.attr[Label]))

}

