#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <time.h>

#define MAX_VERT 10000
#define MAX_WEI 1000
#define INF INT_MAX

typedef struct {
    int val; 
    int cap;  
    int *dat; 
    int *ind; 
} MinHeap;

MinHeap *create_min_heap(int capacity);

void insert(MinHeap *heap, int value, int index);

int extract_min(MinHeap *heap);

void decrease_key(MinHeap *heap, int index, int new_value);

int is_empty(MinHeap *heap);

void free_min_heap(MinHeap *heap);

typedef struct {
    int **adj_matrix; 
    int num_vert; 
} Graph;

Graph *create_graph(int num_vertices);

void generate_connected_graph(Graph *graph);

void generate_grid_graph(Graph *graph);

void dijkstra(Graph *graph, int start_vertex, int *distances);

void free_graph(Graph *graph);

void print_shortest_paths(int *distances, int num_vertices, int start_vertex, FILE* file) {
    fprintf(file, "kratkiy put do vershiny %d:\n", start_vertex);
    for (int i = 0; i < num_vertices; i++) {
        fprintf(file, "do vershiny %d: %d\n", i + 1, distances[i]);
    }
}

int main() {

    srand(time(NULL));

    FILE *file = fopen("result.txt", "w");
    if(file == NULL){
        return 1;
    }

    int num_vertices = 20; 
    Graph *connected_graph = create_graph(num_vertices);
    generate_connected_graph(connected_graph);
    int start_vertex = 0;
    int *distances_connected = (int *) malloc(num_vertices * sizeof(int));
    clock_t start_time = clock();
    dijkstra(connected_graph, start_vertex, distances_connected);
    clock_t end_time = clock();
    double execution_time = (double)(end_time - start_time) / CLOCKS_PER_SEC;
    printf("sviasniy graf is 20 vershin:\n");
    print_shortest_paths(distances_connected, num_vertices, start_vertex + 1, file);
    printf("vremia vipolnenia: %f secund\n\n", execution_time);
    num_vertices = 10000;
    Graph *grid_graph = create_graph(num_vertices);
    generate_grid_graph(grid_graph);
    int *distances_grid = (int *) malloc(num_vertices * sizeof(int));
    start_time = clock();
    dijkstra(grid_graph, start_vertex, distances_grid);
    end_time = clock();
    execution_time = (double)(end_time - start_time) / CLOCKS_PER_SEC;
    printf("graf-reshetka rasmerom 100x100 vershin:\n");
    print_shortest_paths(distances_grid, num_vertices, start_vertex + 1, file);
    printf("vremia vipolnenia: %f secund\n", execution_time);
    free(distances_connected);
    free(distances_grid);
    free_graph(connected_graph);
    free_graph(grid_graph);
    fclose(file);
    return 0;
}

MinHeap *create_min_heap(int capacity) {
    MinHeap *heap = (MinHeap *)malloc(sizeof(MinHeap));
    heap->val = 0;
    heap->cap = capacity;
    heap->dat = (int *)malloc(capacity * sizeof(int));
    heap->ind = (int *)malloc(capacity * sizeof(int));
    return heap;
}

void insert(MinHeap *heap, int value, int index) {
    int i = heap->val++;
    while (i && value < heap->dat[(i - 1) / 2]) {
        heap->dat[i] = heap->dat[(i - 1) / 2];
        heap->ind[i] = heap->ind[(i - 1) / 2];
        i = (i - 1) / 2;
    }
    heap->dat[i] = value;
    heap->ind[i] = index;
}

int extract_min(MinHeap *heap) {
    int min_index = heap->ind[0];
    int last_value = heap->dat[--heap->val];
    int last_index = heap->ind[heap->val];
    int i = 0, j = 1;
    while (j < heap->val) {
        if (j + 1 < heap->val && heap->dat[j] > heap->dat[j + 1]) j++;
        if (last_value <= heap->dat[j]) break;
        heap->dat[i] = heap->dat[j];
        heap->ind[i] = heap->ind[j];
        i = j;
        j = 2 * j + 1;
    }
    heap->dat[i] = last_value;
    heap->ind[i] = last_index;
    return min_index;
}

void decrease_key(MinHeap *heap, int index, int new_value) {
    for (int i = 0; i < heap->val; i++) {
        if (heap->ind[i] == index) {
            heap->dat[i] = new_value;
            while (i && new_value < heap->dat[(i - 1) / 2]) {
                int temp = heap->dat[(i - 1) / 2];
                heap->dat[(i - 1) / 2] = heap->dat[i];
                heap->dat[i] = temp;

                temp = heap->ind[(i - 1) / 2];
                heap->ind[(i - 1) / 2] = heap->ind[i];
                heap->ind[i] = temp;
                i = (i - 1) / 2;
            }
            break;
        }
    }
}

int is_empty(MinHeap *heap) {
    return heap->val == 0;
}

void free_min_heap(MinHeap *heap) {
    free(heap->dat);
    free(heap->ind);
    free(heap);
}

Graph *create_graph(int num_vert) {
    Graph *graph = (Graph *)malloc(sizeof(Graph));
    graph->num_vert = num_vert;
    graph->adj_matrix = (int **)malloc(num_vert * sizeof(int *));
        for (int i = 0; i < num_vert; i++) {
        graph->adj_matrix[i] = (int *)malloc(num_vert * sizeof(int));
        for (int j = 0; j < num_vert; j++) {
            if (i == j) {
                graph->adj_matrix[i][j] = 0;
            } else {
                graph->adj_matrix[i][j] = INF;
            }
        }
    }
    return graph;
}

void generate_connected_graph(Graph *graph) {
    for (int i = 0; i < graph->num_vert - 1; i++) {
        for (int j = i + 1; j < graph->num_vert; j++) {
            int weight = 1 + rand() % MAX_WEI;
            graph->adj_matrix[i][j] = graph->adj_matrix[j][i] = weight;
        }
    }
}

void generate_grid_graph(Graph *graph) {
    int grid_size = 100;
    for (int i = 0; i < grid_size; i++) {
        for (int j = 0; j < grid_size; j++) {
            int vertex = i * grid_size + j;
            if (j + 1 < grid_size) {
                int weight = 1 + rand() % MAX_WEI;
                graph->adj_matrix[vertex][vertex + 1] = weight;
                graph->adj_matrix[vertex + 1][vertex] = weight;
            }
            if (i + 1 < grid_size) {
                int weight = 1 + rand() % MAX_WEI;
                graph->adj_matrix[vertex][vertex + grid_size] = weight;
                graph->adj_matrix[vertex + grid_size][vertex] = weight;
            }
        }
    }
}

void dijkstra(Graph *graph, int start_vertex, int *distances) {
    MinHeap *heap = create_min_heap(graph->num_vert);
    for (int i = 0; i < graph->num_vert; i++) {
        distances[i] = INF;
        insert(heap, distances[i], i);
    }
    distances[start_vertex] = 0;
    decrease_key(heap, start_vertex, 0);

    while (!is_empty(heap)) {
        int current_vertex = extract_min(heap);
        for (int i = 0; i < graph->num_vert; i++) {
            int weight = graph->adj_matrix[current_vertex][i];
            if (weight != INF) {
                int alt = distances[current_vertex] + weight;
                if (alt < distances[i]) {
                    distances[i] = alt;
                    decrease_key(heap, i, alt);
                }
            }
        }
    }

    free_min_heap(heap);
}

void free_graph(Graph *graph) {
    for (int i = 0; i < graph->num_vert; i++) {
        free(graph->adj_matrix[i]);
    }
    free(graph->adj_matrix);
    free(graph);
}