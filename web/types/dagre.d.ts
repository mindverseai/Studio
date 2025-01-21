declare module "@dagrejs/dagre" {
  interface GraphLabel {
    width?: number;
    height?: number;
    rank?: string;
    rankdir?: "TB" | "BT" | "LR" | "RL"; // TB = top-bottom, BT = bottom-top, LR = left-right, RL = right-left
    align?: "UL" | "UR" | "DL" | "DR"; // UL = upper-left, UR = upper-right, DL = down-left, DR = down-right
    nodesep?: number; // Minimaler Abstand zwischen zwei Knoten in derselben Ebene
    ranksep?: number; // Minimaler Abstand zwischen zwei Ebenen
    ranker?: "network-simplex" | "tight-tree" | "longest-path"; // Algorithmus für das Ranking der Knoten
    marginx?: number; // Horizontaler Randabstand des Graphen
    marginy?: number; // Vertikaler Randabstand des Graphen
  }

  interface Edge {
    v: string;
    w: string;
    name?: string;
  }

  interface Graph {
    setDefaultEdgeLabel(callback: () => any): void;
    setGraph(label: GraphLabel): void;
    graph(): GraphLabel;
    setNode(name: string, label: any): void;
    node(name: string): any;
    setEdge(v: string, w: string, name?: string): void;
    edges(): Edge[];
    nodes(): string[];
  }

  interface DagreStatic {
    graphlib: {
      Graph: new () => Graph;
    };
    layout(g: Graph): void;
  }

  const dagre: DagreStatic;
  export default dagre;
}
