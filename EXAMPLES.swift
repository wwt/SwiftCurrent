WorkflowView {
    WorkflowItem(FR1.self)
}


WorkflowView {
    FR1(with: "Where does this come from?")
}.withArguments("This is where it comes from.")

/////// DESIRED VIEW???? ///////////////
struct FR1: View, FlowRepresentable {
    let importantArg: String
    init(with args: String) { importantArg = args }

    var body: some View { Text("WE MADE IT") }

    func shouldLoad() -> Bool {
        importantArg.contains("@wwt.com")
    }
}


/////////////// MODAL STYLE //////////////////
✅ Able to apply view modifiers on a per view basis (especially transition animations).
✅ Able to read the Workflow when there are many views present (at least 10).
Able to swap inline definition of views with a variable/property
✅ Completion syntax makes sense when everything is inlined.
✅ We have a way to abandon the Workflow.
✅ We can set persistence and launch styles on a per view basis (most likely just another view modifier).

let sequenceOfViews: @ViewBuilder () -> some View = {
    WorkflowItem(FR1.self)
    WorkflowItem(FR2.self)
    WorkflowItem(FR3.self)
        .transition(.opaque)
    WorkflowItem(FR4.self)
        .transition(.slide)
    WorkflowItem(FR5.self)
    WorkflowItem(FR6.self)
    WorkflowItem(FR7.self)
        .persistence(.removedAfterProceeding)
        .launchStyle(.modal)
        .padding()
        .background(Color.red)
    WorkflowItem(FR8.self)
    WorkflowItem(FR9.self)
        .launchStyle(.navigation)
        .transition(.slide)
    WorkflowItem(FR10.self)
}

@State var presented = false
var body: some View {
    WorkflowView(isPresented: $presented, 
                 workflow: { sequenceOfViews }, 
                 completionAction: { presented = false }
    )

    WorkflowView(isPresented: $presented, 
                 workflow: { 
                    WorkflowItem(FR1.self)
                    WorkflowItem(FR2.self)
                    WorkflowItem(FR3.self)
                        .transition(.opaque)
                    WorkflowItem(FR4.self)
                        .transition(.slide)
                    WorkflowItem(FR5.self)
                    WorkflowItem(FR6.self)
                    WorkflowItem(FR7.self)
                        .persistence(.removedAfterProceeding)
                        .launchStyle(.modal)
                        .padding()
                        .background(Color.red)
                    WorkflowItem(FR8.self)
                    WorkflowItem(FR9.self)
                        .launchStyle(.navigation)
                        .transition(.slide)
                    WorkflowItem(FR10.self)
                 }, 
                 completionAction: { presented = false }
    )

    Button("Do the workflow thing") { presented.toggle() }
}




//////////////// RIFFING AREA ///////////////////
let workyflowy = {
    WorkflowItem(FR1.self)
    WorkflowItem(FR2.self)
    WorkflowItem(FR3.self)
    WorkflowItem(FR4.self)
    WorkflowItem(FR5.self)
    WorkflowItem(FR6.self)
    WorkflowItem(FR7.self)
    WorkflowItem(FR8.self)
    WorkflowItem(FR9.self)
    WorkflowItem(FR10.self)
}

@State var abandonWorkflow = false

var body: some View {
    WorkflowView({
            workyflowy
        },
        completionAction: { argsIncoming in
            Text("You have completed this workflow: \(argsIncoming)")
            abandonWorkflow = true
        }
    ).launchStyle(.navigationLink)
    .abandonState($abandonWorkflow)


    Button("Text") {
        abandonWorkflow.toggle()
    }
}




extension Workflow {
    func launch() -> some View {}
}