#include <iostream>
#include <vector>
#include <stack>

using namespace std;

void dfs(int vertex, const vector<vector<int>>& graph, vector<bool>& visited, vector<int>& component) {
    visited[vertex] = true;
    component.push_back(vertex);

    for (int neighbor = 0; neighbor < graph.size(); ++neighbor) {
        if (graph[vertex][neighbor] == 1 && !visited[neighbor]) {
            dfs(neighbor, graph, visited, component);
        }
    }
}

void dfsReverse(int vertex, const vector<vector<int>>& reverseGraph, vector<bool>& visited, stack<int>& vertexStack) {
    visited[vertex] = true;

    for (int neighbor = 0; neighbor < reverseGraph.size(); ++neighbor) {
        if (reverseGraph[vertex][neighbor] == 1 && !visited[neighbor]) {
            dfsReverse(neighbor, reverseGraph, visited, vertexStack);
        }
    }

    vertexStack.push(vertex);
}

vector<vector<int>> findConnectedComponents(const vector<vector<int>>& graph) {
    int numVertices = graph.size();
    vector<bool> visited(numVertices, false);
    stack<int> vertexStack;

    // Поиск в глубину в обратном графе для формирования стека вершин
    for (int vertex = 0; vertex < numVertices; ++vertex) {
        if (!visited[vertex]) {
            dfsReverse(vertex, graph, visited, vertexStack);
        }
    }

    // Создание обратного графа
    vector<vector<int>> reverseGraph(numVertices, vector<int>(numVertices, 0));
    for (int i = 0; i < numVertices; ++i) {
        for (int j = 0; j < numVertices; ++j) {
            reverseGraph[i][j] = graph[j][i];
        }
    }

    // Сброс состояния visited
    visited.assign(numVertices, false);

    vector<vector<int>> components;

    // Поиск компонент связности в обратном графе
    while (!vertexStack.empty()) {
        int vertex = vertexStack.top();
        vertexStack.pop();

        if (!visited[vertex]) {
            vector<int> component;
            dfs(vertex, reverseGraph, visited, component);
            components.push_back(component);
        }
    }

    return components;
}

void printMatrixExample() {
    cout << "Пример матрицы смежности (4 вершины):" << endl;
    cout << "0 1 1 0" << endl;
    cout << "1 0 0 1" << endl;
    cout << "1 0 0 0" << endl;
    cout << "0 1 0 0" << endl;
    cout << endl;
}

int main() {
    int numVertices;
    cout << "Введите количество вершин графа: ";
    cin >> numVertices;

    vector<vector<int>> graph(numVertices, vector<int>(numVertices, 0));

    printMatrixExample();

    cout << "Введите матрицу смежности:" << endl;
    for (int i = 0; i < numVertices; ++i) {
        for (int j = 0; j < numVertices; ++j) {
            cin >> graph[i][j];
        }
    }

    vector<vector<int>> components = findConnectedComponents(graph);
    int numComponents = components.size();

    cout << "Количество компонент связности: " << numComponents << endl;

    for (int i = 0; i < numComponents; ++i) {
    cout << "Компонента " << (i + 1) << ": ";
    for (int vertex : components[i]) {
        cout << (vertex + 1) << " ";
    }
    cout << endl;
    }

    return 0;
}
