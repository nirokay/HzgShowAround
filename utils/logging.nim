import std/[strutils, strformat, sequtils, tables]
import websitegenerator

type Logger* = object
    generatedHtml*, generatedCss*, generatedSvg*, generatedXml*: seq[string]
    failures*: OrderedTable[string, seq[string]]

proc announceGeneration(logger: var Logger, path, emoji: string) =
    stdout.write(emoji & " '" & path & "'...")
    stdout.flushFile()
proc announceGeneration*(logger: var Logger, document: HtmlDocument) =
    logger.announceGeneration(document.file, "📄")
proc announceGeneration*(logger: var Logger, document: XmlDocument) =
    logger.announceGeneration(document.file, "📊")
proc announceGeneration*(logger: var Logger, stylesheet: CssStyleSheet) =
    logger.announceGeneration(stylesheet.file, "💅")

proc addGenerated*(logger: var Logger, document: HtmlDocument) =
    ## Adds file to generated list
    let path: string = document.file
    logger.generatedHtml.add path
    stdout.write("\r📄 Finished generation for '" & path & "'!\n")
    stdout.flushFile()
proc addGenerated*(logger: var Logger, document: XmlDocument) =
    ## Adds file to generated list
    let path: string = document.file
    logger.generatedXml.add path
    stdout.write("\r📊 Finished generation for '" & path & "'!\n")
    stdout.flushFile()
proc addGenerated*(logger: var Logger, stylesheet: CssStyleSheet) =
    ## Adds file to generated list
    let path: string = stylesheet.file
    logger.generatedCss.add path
    stdout.write("\r💅 Finished generation for '" & path & "'!\n")
    stdout.flushFile()
proc addGeneratedSvg*(logger: var Logger, path: string, curr, goal: int) =
    ## Adds file to generated list
    logger.generatedSvg.add path
    stdout.write(&"\r✏️ SVG: '{path}' ({curr}/{goal})")
    stdout.flushFile()

proc addFailure(logger: var Logger, path, reason: string) =
    ## Adds new error
    if likely(not logger.failures.hasKey(reason)):
        logger.failures[reason] = @[]
    logger.failures[reason] &= path
proc addFailure*(logger: var Logger, document: HtmlDocument, reason: string = "Generic Failure") =
    logger.addFailure(document.file, reason)
proc addFailure*(logger: var Logger, document: XmlDocument, reason: string = "Generic Failure") =
    logger.addFailure(document.file, reason)
proc addFailure*(logger: var Logger, stylesheet: CssStyleSheet, reason: string = "Generic Failure") =
    logger.addFailure(stylesheet.file, reason)

proc postGenerationLog*(logger: Logger) =
    echo @[
        "\n",
        "Post-Generation Log:",
        "--------------------\n",
        "Generated HTML: " & $logger.generatedHtml.len(),
        "Generated XML:  " & $logger.generatedXml.len(),
        "Generated CSS:  " & $logger.generatedCss.len(),
        "Generated SVG:  " & $logger.generatedSvg.deduplicate().len()
    ].join("\n")
    if logger.failures.len() != 0:
        echo "\nErrors:"
        let sep: string = "    * "
        for reason, list in logger.failures:
            echo "  " & reason & ":\n" & sep & list.join("\n" & sep)


var logger*: Logger = Logger()
